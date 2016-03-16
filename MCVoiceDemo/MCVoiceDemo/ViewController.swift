//
//  ViewController.swift
//  MCVoiceDemo
//
//  Created by 马超 on 16/3/9.
//  Copyright © 2016年 @qq:714080794 (交流qq). All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox;


let ID = "ID"

class ViewController: UIViewController,EZMicrophoneDelegate,EZAudioFFTDelegate,EZRecorderDelegate,UITableViewDelegate,UITableViewDataSource ,VoicePlayViewDelegate,STKAudioPlayerDelegate{

    var recordBtn: UIButton!
    var recordView: MCRecordView?
    var microphone: EZMicrophone!
    var fft: EZAudioFFT!
    var record: EZRecorder!
    var tableView: UITableView!
    var data: Array<String> = Array()
    var startTime: String?
    var audioPlayer: STKAudioPlayer!
    var currentCell: VoicePlayView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setupTableView()
        self.setupRecordButton()
        
        let session = AVAudioSession.sharedInstance()
        do {
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            
        }catch {
            
        }
        
//        var desc = AudioStreamBasicDescription()
//        desc.mSampleRate = 8000.0
//        desc.mFormatID = kAudioFormatLinearPCM
//        desc.mBitsPerChannel = 1
        self.microphone = EZMicrophone(delegate: self)
        self.fft = EZAudioFFT(maximumBufferSize: 4096, sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        
        var option = STKAudioPlayerOptions()
        option.flushQueueOnSeek = true
        option.enableVolumeMixer = false
        //        option.equalizerBandFrequencies = (Float32(50), Float32(100), Float32(200), Float32(400), Float32(800), Float32(1600), Float32(2600), Float32(16000)) as! (Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32)
         audioPlayer = STKAudioPlayer(options: option)
        audioPlayer.meteringEnabled = true
        audioPlayer.volume = 1
        audioPlayer.muted = false
        audioPlayer.delegate = self
        
        
        //添加监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sensorStateChange:", name: "UIDeviceProximityStateDidChangeNotification", object: nil)
        
        
     
    }

    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func sensorStateChange(not: NSNotificationCenter) {
        
        if UIDevice.currentDevice().proximityState == true {
            self.setSessionPlayAndRecord()
        }else {
            self.setSessionPlayBack()
        }
    }
    func uploadToServer() {
        
        self.data.insert(self.startTime!, atIndex: 0)
        self.tableView.reloadData()
        //wav 路径
        let wavPath = self.applicationDocumentsDirectory() + "/new.wav"
        // amr 路径
        let amrPath = self.applicationDocumentsDirectory() + "/audio.wav"
        //
        let toPath = self.applicationDocumentsDirectory() + "/dddd.wav"
        let data = NSData(contentsOfFile: amrPath)
        
//        let amrData = EncodeAudio.convertWavToAmrFile(data)
        
        let wavData = EncodeAudio.convertAmrToWavFile(data)
        //写入文件
        wavData.writeToFile(toPath, atomically: true)

    }
   
    func setupTableView() {
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
        tableView.sd_layout()
        .leftSpaceToView(self.view,0)
        .rightSpaceToView(self.view,0)
        .topSpaceToView(self.view,0)
        .bottomSpaceToView(self.view,0)
        
    }
    func setupRecordButton() {
        
        recordBtn = UIButton()
        recordBtn.setTitle("按住录音", forState: UIControlState.Normal)
        recordBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        recordBtn.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
        recordBtn.setTitle("正在录音...", forState: UIControlState.Highlighted)
        view.addSubview(recordBtn)
        
        recordBtn.sd_layout()
        .leftSpaceToView(self.view,0)
        .rightSpaceToView(self.view ,0)
        .bottomSpaceToView(self.view , 0)
        .heightIs(44)
        
        recordBtn.addTarget(self, action: "recordBtnTouchDown", forControlEvents: UIControlEvents.TouchDown)
        recordBtn.addTarget(self, action: "recordBtnTouchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
        recordBtn.addTarget(self, action: "recordBtnTouchUpOutside", forControlEvents: UIControlEvents.TouchUpOutside)
        recordBtn.addTarget(self, action: "recordBtnTouchDragEnter", forControlEvents: UIControlEvents.TouchDragEnter)
        recordBtn.addTarget(self, action: "recordBtnTouchDragOutside", forControlEvents: UIControlEvents.TouchDragOutside)
    }
    
    
    //MARK: ---------- button func ----------
    func recordBtnTouchDown() {
        
        if let _ = self.recordView {
            
            self.recordView!.show()
        }else {
            
            self.recordView = MCRecordView()
            self.recordView!.show()
        }
        
        self.microphone.startFetchingAudio()
        self.record = EZRecorder(URL: self.filePathURL(), clientFormat: self.microphone.audioStreamBasicDescription(), fileType: EZRecorderFileType.WAV, delegate: self)

    }
    
    func recordBtnTouchUpInside() {
        
        if let _ = self.recordView {
            
            self.recordView!.dissmiss()
            self.microphone.stopFetchingAudio()
            self.record.closeAudioFile()
            
            //发送到服务器
            self.uploadToServer()
        }
    }
    
    func recordBtnTouchUpOutside() {
        
        if let _ = self.recordView {
            
            self.recordView!.dissmiss()
            self.microphone.stopFetchingAudio()
            self.record.closeAudioFile()
        }
    }
 
    func recordBtnTouchDragEnter() {
        
        if let _ = self.recordView {
            
            self.recordView!.willShow()
        }
    }
    
    func recordBtnTouchDragOutside() {
        
        if let _ = self.recordView {
            
            self.recordView!.willDissmiss()
        }
    }


    
    //MARK:  -------- 麦克风的代理 -----------
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {

       self.fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioStreamBasicDescription audioStreamBasicDescription: AudioStreamBasicDescription) {
        
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        if let _ = self.record {
            self.record.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    
    func microphone(microphone: EZMicrophone!, changedDevice device: EZAudioDevice!) {
        
    }
    
    //
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        
        let fft = fft.maxFrequency
        
        
        var num = fft / 200
        if num > 8 {
            num = 8
        }else if num < 1 {
            num = 1
        }
        print(Int(num))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC) )), dispatch_get_main_queue()) { () -> Void in
            
            self.recordView!.updateVoiceNum(Int(num))
        }
  
    }
    
    //MARK: ------ ezrecord delegate ------ 
    func recorderDidClose(recorder: EZRecorder!) {
        
        record.delegate = nil
    }
    
    //MARK: ----- private ------
    func applicationDocumentsDirectory() -> String {
     
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let basePath = paths.count > 0 ? paths.first : ""
        return basePath!
    }
    
    func filePathURL() -> NSURL{
        
        self.startTime = self.getCurrentTimeString()
        return NSURL(fileURLWithPath: "\(self.applicationDocumentsDirectory())/\(self.startTime!).wav")
    
    }
    
    //MARK:  ------------  tableview --------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        var cell = tableView.dequeueReusableCellWithIdentifier(ID)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: ID)
            
            let play = VoicePlayView()
            play.frame = CGRectMake(20, 20, 120, 35)
            cell!.contentView.addSubview(play)
            play.delegate = self
        }
        
        for obj in cell!.contentView.subviews {
            if obj.isKindOfClass(VoicePlayView.self) {
                
                let voice = obj as! VoicePlayView
                voice.model = self.data[indexPath.row]
                voice.playBtn.setTitle("", forState: UIControlState.Normal)
            }
        }
    
        return cell!
        
    }
    
    func getCurrentTimeString() -> String {
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyyMMddHHmmss"
        return dateFormat.stringFromDate(NSDate())
    }
    
    
    func clicked(voiceView: VoicePlayView) {
        
        if voiceView.playBtn.selected {
            
            self.currentCell = voiceView
            
            let model = voiceView.model as! String
            

            let path = self.applicationDocumentsDirectory() + "/\(model).wav";
            let url = NSURL(fileURLWithPath: path)
            
            let data = NSData(contentsOfFile: path)
            
            let amrData = EncodeAudio.convertWavToAmrFile(data)
            
            let wavData = EncodeAudio.convertAmrToWavFile(amrData)
            
            let dataSource = STKAudioPlayer.dataSourceFromURL(url)
            
            audioPlayer.setDataSource(dataSource, withQueueItemId: SampleQueueId(url: url, andCount: 0))
            

           
        }else {
            
            self.currentCell = nil
            audioPlayer.stop()
         
        }

  }
  
    //MARK: --------- audio delegate --------
    func audioPlayer(audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        
        let d = Int(self.audioPlayer.duration)
        if let _ = self.currentCell {
            self.currentCell!.playBtn.setTitle("\(d)", forState: UIControlState.Normal)
        }
        
        self.setSessionPlayBack()
        UIDevice.currentDevice().proximityMonitoringEnabled = true
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        
        let d = Int(self.audioPlayer.duration)
        if let _ = self.currentCell {
            self.currentCell!.playBtn.setTitle("\(d)", forState: UIControlState.Normal)
        }
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        
        if let _ = self.currentCell {
            self.currentCell!.stopAnimating()
        }
        self.setSessionPlayAndRecord()
        UIDevice.currentDevice().proximityMonitoringEnabled = false
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        
        self.setSessionPlayAndRecord()
         UIDevice.currentDevice().proximityMonitoringEnabled = false
    }
    
    func setSessionPlayBack () {
        
        let session = AVAudioSession.sharedInstance()
        do {
            
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
            
        }catch {
            
        }
    }
    
    func setSessionPlayAndRecord () {
        
        let session = AVAudioSession.sharedInstance()
        do {
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            
        }catch {
            
        }
    }
}


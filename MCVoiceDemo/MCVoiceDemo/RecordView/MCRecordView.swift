//
//  MCRecordView.swift
//  MCVoiceDemo
//
//  Created by 马超 on 16/3/9.
//  Copyright © 2016年 @qq:714080794 (交流qq). All rights reserved.
//

import UIKit

let kWidth: Float = 180.0

class MCRecordView: UIView {

    var bgLayer: CALayer!
    var microphoneLayer: CALayer!
    var voiceNumLayer: CALayer!
    var descLabel: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: --------  将要取消  -----------
    func willDissmiss() {
        
        descLabel.text = "松开手指,取消发送"
        descLabel.backgroundColor = UIColor.redColor()
    }
    
    //MARK: --------  未取消  -----------
    func willShow() {
        
        descLabel.text = "手指上滑,取消发送"
        descLabel.backgroundColor = UIColor.clearColor()
    }
    
    //MARK: --------- 显示  ------------
    func show() {
        
        let window = UIApplication.sharedApplication().keyWindow!
        self.frame = window.bounds
        window.addSubview(self)
    }
    
    //MARK: ---------- 取消 -----------
    func dissmiss() {
        
        self.removeFromSuperview()
    }
    
    //MARK: -------- 更新音量 -----------
    func updateVoiceNum(num: Int) {
        
        let imageStr = "RecordingSignal00\(num)"
        let image = UIImage(named: imageStr)?.CGImage
        voiceNumLayer.contents = image as? AnyObject
        
    }
    //MARK: -------- 子空间布局 ------------
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.setupBgLayer()
        self.setupMicrophoneLayer()
        self.setupVoiceNumLayer()
        self.setupDescLabel()
        
    }
    func setupBgLayer() {
        
        bgLayer = CALayer()
        bgLayer.backgroundColor = UIColor(white: 0.3, alpha: 1.0).CGColor
        bgLayer.cornerRadius = 5.0
        self.layer.addSublayer(bgLayer)
        
        let w: Float = kWidth
        let h = w
        let x = (Float(self.frame.width) - w) * 0.5
        let y = (Float(self.frame.height) - h) * 0.5
        
        bgLayer.frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(w), CGFloat(h))
        
    }
    
    func setupMicrophoneLayer() {
        
        microphoneLayer = CALayer()
        let image = UIImage(named: "RecordingBkg")?.CGImage
        microphoneLayer.contents = image as? AnyObject
        bgLayer.addSublayer(microphoneLayer)
        
        let w: Float = kWidth * 0.5 - 20
        let h = bgLayer.frame.height - 40
        let x = 35.0
        let y = 0.0
        
        microphoneLayer.frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(w), CGFloat(h))
    }
    
    func setupVoiceNumLayer() {
        
        voiceNumLayer = CALayer()
        let image = UIImage(named: "RecordingSignal001")?.CGImage
        voiceNumLayer.contents = image as? AnyObject
        bgLayer.addSublayer(voiceNumLayer)
        
        let w: Float = kWidth * 0.5 - 20
        let h = bgLayer.frame.height - 40
        let x = CGRectGetMaxX(microphoneLayer.frame)
        let y = 0.0
        
        voiceNumLayer.frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(w), CGFloat(h))
    }
    
    
    func setupDescLabel() {
        
        descLabel = UILabel()
        descLabel.text = "手指上滑,取消发送"
        descLabel.font = UIFont.systemFontOfSize(13.0)
        descLabel.textColor = UIColor.whiteColor()
        descLabel.textAlignment = NSTextAlignment.Center
        descLabel.layer.cornerRadius = 3
        descLabel.clipsToBounds = true
        
        bgLayer.addSublayer(descLabel.layer)
        
        descLabel.frame = CGRectMake((bgLayer.frame.width - 110) * 0.5, bgLayer.frame.height - 30, 110, 20)
    }
}

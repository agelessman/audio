//
//  VoicePlayView.swift
//  MCVoiceDemo
//
//  Created by 马超 on 16/3/10.
//  Copyright © 2016年 @qq:714080794 (交流qq). All rights reserved.
//

import UIKit

protocol VoicePlayViewDelegate {
    
    func clicked(voiceView: VoicePlayView)
}

class VoicePlayView: UIView {

    var playBtn: UIButton!
    var model: AnyObject?
    var delegate: VoicePlayViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setupPlayBtn()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        playBtn.frame = self.bounds
        
      let title = playBtn.titleForState(UIControlState.Normal)
        if let _ = title {
            
            playBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -self.bounds.size.width + 40 , 0, self.bounds.size.width - 40)
            
             playBtn.titleEdgeInsets = UIEdgeInsetsMake(1, -8, 0, 8)

            playBtn.imageView?.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 0, 1.0)

        }
        
    }
    
    func setupPlayBtn() {
        
        playBtn = UIButton()
        playBtn.setImage(UIImage(named: "SenderVoiceNodePlaying003"), forState: UIControlState.Normal)
        playBtn.backgroundColor = UIColor.lightGrayColor()
        playBtn.layer.cornerRadius = 3
        playBtn.clipsToBounds = false
        playBtn.imageView?.animationDuration = 2.0
        playBtn.imageView?.animationRepeatCount = 10000
        playBtn.setTitle("0\"", forState: UIControlState.Normal)
        playBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        playBtn.titleLabel?.font = UIFont.systemFontOfSize(12.0)
        playBtn.imageView?.contentMode = UIViewContentMode.Center
        playBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        self.addSubview(playBtn)
        

        playBtn.addTarget(self, action: "playAction", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    func playAction() {
        
        playBtn.selected = !playBtn.selected
        
        if playBtn.selected {
            
            self.startAnimating()
        }else {
            
            self.stopAnimating()
        }
        
        if let _ = self.delegate {
            
            self.delegate!.clicked(self)
        }
    }
    
    
    func startAnimating() {
        
        if !playBtn.imageView!.isAnimating() {
            
            let image0 = UIImage(named: "SenderVoiceNodePlaying001")
            let image1 = UIImage(named: "SenderVoiceNodePlaying002")
            let image2 = UIImage(named: "SenderVoiceNodePlaying003")
            playBtn.imageView!.animationImages = [image0!,image1!,image2!]
            playBtn.imageView!.startAnimating()
        }
    }
    
    func stopAnimating() {
        
        if playBtn.imageView!.isAnimating() {
            playBtn.imageView!.stopAnimating()
        }
    }
}

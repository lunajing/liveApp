//
//  LALiveShowingViewController.swift
//  liveApp
//
//  Created by luna on 2017/5/5.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import LFLiveKit

class LALiveShowingViewController: UIViewController, LFLiveSessionDelegate {

    var session: LFLiveSession!
    var livingPreView: UIView!
    var rtmpUrl: String!
    var preview:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        title = "视频采集"
        view.backgroundColor = UIColor.white
        
        preview = UIView(frame: self.view.bounds)
        view.insertSubview(preview, at: 0)
        
        session = LFLiveSession.init(audioConfiguration: LFLiveAudioConfiguration.default(), videoConfiguration: LFLiveVideoConfiguration.defaultConfiguration(for: .medium2), captureType: .captureDefaultMask)
        session.delegate = self
        session.running = true
        session.preView = preview
        
        session.captureDevicePosition = .back
        
        let button = UIButton()
        button.setTitle("切换摄像头", for: .normal)
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(100)
        }
        button.addTarget(self, action: #selector(changeCamreraPostion), for: .touchUpInside)
        
        let switchI = UISwitch()
        switchI.addTarget(self, action: #selector(beauty(_:)), for: .valueChanged)
        view.addSubview(switchI)
        switchI.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(button.snp.bottom).offset(50)
        }
        
        let button1 = UIButton()
        button1.setTitle("开始直播", for: .normal)
        button1.setTitle("结束直播", for: .selected)
        view.addSubview(button1)
        button1.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(switchI.snp.bottom).offset(50)
        }
        button1.addTarget(self, action: #selector(startLiving(_:)), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        session.stopLive()
    }
    
    func beauty(_ sender: UISwitch) {
        session.beautyFace = sender.isOn
    }
    
    func startLiving(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            let stream = LFLiveStreamInfo()
            stream.url = "rtmp://10.1.1.102:1990/liveApp/room"
            rtmpUrl = stream.url!
            session.startLive(stream)
            NSLog("直播开始")
        }else{
            session.stopLive()
            NSLog("直播结束")
        }
    }
    
    
    func changeCamreraPostion() {
        let devicePosition = session.captureDevicePosition
        session.captureDevicePosition = devicePosition == .front ? .back : .front
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

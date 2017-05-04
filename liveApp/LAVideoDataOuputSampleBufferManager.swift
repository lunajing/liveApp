//
//  LAVideoDataOuputSampleBufferManager.swift
//  liveApp
//
//  Created by luna on 2017/4/1.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import AVFoundation

class LAVideoDataOuputSampleBufferManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = LAVideoDataOuputSampleBufferManager()
    
    var videoOutput: AVCaptureVideoDataOutput!
    
    private override init() {
        super.init()
        // .获取视频数据输出设备
        videoOutput = AVCaptureVideoDataOutput()
        // 7.1 设置代理，捕获视频样品数据
        // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
        let videoQueue = DispatchQueue.init(label: "Video Capture Queue")
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
    }
}

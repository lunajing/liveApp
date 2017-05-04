//
//  LAAudioDataOuputSampleBufferManager.swift
//  liveApp
//
//  Created by luna on 2017/4/1.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import AVFoundation

class LAAudioDataOuputSampleBufferManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = LAAudioDataOuputSampleBufferManager()
    
    var audioOutput: AVCaptureAudioDataOutput!
    
    private override init() {
        super.init()
        audioOutput = AVCaptureAudioDataOutput()
        let audioQueue = DispatchQueue.init(label: "Audio Capture Queue")
        //audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
    }
}

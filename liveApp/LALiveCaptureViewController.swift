//
//  LALiveCaptureViewController.swift
//  liveApp
//
//  Created by luna on 2017/4/1.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

class LALiveCaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var currentVideoDeviceInput: AVCaptureDeviceInput!
    var previedLayer: AVCaptureVideoPreviewLayer!
    var videoConnection: AVCaptureConnection!
    var audioConnection: AVCaptureConnection!
    var focusCursorImageView: UIImageView!
    
    var videoCamera: GPUImageVideoCamera!
    var captuerVideoPreview:GPUImageView!
    var bilateralFilter:GPUImageBilateralFilter!
    var brightnessFilter: GPUImageBrightnessFilter!
    var groupFilter: GPUImageFilterGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "视频采集"
        view.backgroundColor = UIColor.white
        setupCaptureVideo()
        focusCursorImageView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        view.addSubview(focusCursorImageView)
        focusCursorImageView.alpha = 0
        
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
        
        GPUCamera()
    }
    
    func GPUCamera() {
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .front)
        videoCamera.outputImageOrientation = .portrait
        
        captuerVideoPreview = GPUImageView(frame: self.view.bounds)
        view.insertSubview(captuerVideoPreview, at: 0)
        
        //创建组合滤镜
        groupFilter = GPUImageFilterGroup()
        //磨皮
        bilateralFilter = GPUImageBilateralFilter()
        groupFilter.addFilter(bilateralFilter)
        bilateralFilter.distanceNormalizationFactor = 5
        
        //美白
        brightnessFilter = GPUImageBrightnessFilter()
        groupFilter.addFilter(brightnessFilter)
        brightnessFilter.brightness = 0.2
        
        // 设置滤镜组链
        bilateralFilter.addTarget(brightnessFilter)
        groupFilter.initialFilters = [bilateralFilter]
        groupFilter.terminalFilter = brightnessFilter
        
        // 设置GPUImage响应链，从数据源 => 滤镜 => 最终界面效果
        videoCamera.addTarget(groupFilter)
        groupFilter.addTarget(captuerVideoPreview)
        
        videoCamera.startCapture()
    }
    
    //美颜
    func beauty(_ sender: UISwitch) {
        videoCamera.removeAllTargets()
        if sender.isOn {
            let beautyFilter = GPUImageBeautifyFilter()
            videoCamera.addTarget(beautyFilter)
            beautyFilter.addTarget(captuerVideoPreview)
        }else{
            videoCamera.addTarget(groupFilter)
            groupFilter.addTarget(captuerVideoPreview)
        }
    }
    
    func setupCaptureVideo() {
        // 1.创建捕获会话,必须要强引用，否则会被释放
        captureSession = AVCaptureSession()
        // 2.获取摄像头设备，默认是后置摄像头
        let videoDevice = getVideoDevice(position: .front)
        // 3.获取声音设备
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        // 4.创建对应视频设备输入对象
        do {
            currentVideoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch let error {
            NSLog(error.localizedDescription)
        }
        // 5.创建对应音频设备输入对象
        var audioDeviceInput: AVCaptureDeviceInput!
        do {
            audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch let error {
            NSLog(error.localizedDescription)
        }
        
        // 6.添加到会话中
        // 注意“最好要判断是否能添加输入，会话不能添加空的
        // 6.1 添加视频
        if captureSession.canAddInput(currentVideoDeviceInput) {
            captureSession.addInput(currentVideoDeviceInput)
        }
        // 6.2 添加音频
        if captureSession.canAddInput(audioDeviceInput) {
            captureSession.addInput(audioDeviceInput)
        }
        
        // 7.获取视频数据输出设备
        let videoOutput = AVCaptureVideoDataOutput()
        // 7.1 设置代理，捕获视频样品数据
        // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
        let videoQueue = DispatchQueue.init(label: "Video Capture Queue")
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        // 8.获取音频数据输出设备
        let audioOutput = AVCaptureAudioDataOutput()
        let audioQueue = DispatchQueue.init(label: "Audio Capture Queue")
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        }
        
        // 9.获取视频输入与输出连接，用于分辨音视频数据
        videoConnection = videoOutput.connection(withMediaType: AVMediaTypeVideo)
        audioConnection = audioOutput.connection(withMediaType: AVMediaTypeAudio)
        
        // 10.添加视频预览图层
//        previedLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previedLayer.frame = view.bounds
//        view.layer.addSublayer(previedLayer)
        
        // 11.启动会话
        captureSession.startRunning()
    }
    
    // 指定摄像头方向获取摄像头
    func getVideoDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice]
        for device in devices! {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    //MARK:- AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        NSLog("kkk")
    }
    
    //MARK:- AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if audioConnection == connection {
            NSLog("采集到音频")
        }else {
            NSLog("采集到视频")
        }
    }
    
    //MARK:- 切换摄像头,改变方向，重新生成输入设备，add to session
    func changeCamreraPostion() {
        videoCamera.rotateCamera()
        return
        //previedLayer.transform = CATransform3DMakeRotation(180, 0, 1, 0)
        // 获取当前设备方向
        let currentPosition = currentVideoDeviceInput.device.position
        var targetPosition: AVCaptureDevicePosition!
        if currentPosition == .front {
            targetPosition = AVCaptureDevicePosition.back
        }else{
            targetPosition = AVCaptureDevicePosition.front
        }
        let changedDeivce = getVideoDevice(position: targetPosition)
        captureSession.removeInput(currentVideoDeviceInput)
        do {
            currentVideoDeviceInput = try AVCaptureDeviceInput(device: changedDeivce)
        } catch let error {
            NSLog(error.localizedDescription)
        }
        if captureSession.canAddInput(currentVideoDeviceInput) {
            captureSession.addInput(currentVideoDeviceInput)
        }
    }
    
    // 点击屏幕，出现聚焦视图
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        let touch = touches.first
//        let point = touch?.location(in: view)
//        setFocusCursorWithPoint(point: point!)
//        
//        // 把当前位置转换为摄像头点上的位置
//        let cameraPoint = previedLayer.captureDevicePointOfInterest(for: point!)
//        focus(withMode: .autoFocus, exposureMode: .autoExpose, atPoint: cameraPoint)
    }
    
    func setFocusCursorWithPoint(point: CGPoint) {
        focusCursorImageView.center = point
        focusCursorImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        focusCursorImageView.alpha = 1
        UIView.animate(withDuration: 1, animations: { 
            self.focusCursorImageView.transform = CGAffineTransform.identity
        }) { (_) in
            self.focusCursorImageView.alpha = 0
        }
    }
    
    //MARK:- 设置聚焦
    func focus(withMode focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, atPoint point: CGPoint) {
        let device = currentVideoDeviceInput.device
        //锁定配置
        do {
            try device?.lockForConfiguration()
        } catch let error {
            NSLog(error.localizedDescription)
        }
        
        //设置聚焦
        if device!.isFocusModeSupported(focusMode) {
            device!.focusMode = focusMode
        }
        if device!.isFocusPointOfInterestSupported {
            device!.focusPointOfInterest = point
        }
        
        //设置曝光
        if device!.isExposureModeSupported(exposureMode) {
            device!.exposureMode = exposureMode
        }
        if device!.isExposurePointOfInterestSupported {
            device!.exposurePointOfInterest = point
        }
        //解锁设备
        device?.unlockForConfiguration()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

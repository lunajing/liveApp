//
//  TestViewController.swift
//  liveApp
//
//  Created by luna on 2017/4/26.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import GPUImage

class TestViewController: UIViewController {
    var videoCamera: GPUImageVideoCamera!
    var captuerVideoPreview:GPUImageView!
    var bilateralFilter:GPUImageBilateralFilter!
    var brightnessFilter: GPUImageBrightnessFilter!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .front)
        videoCamera.outputImageOrientation = .portrait
        
        
        captuerVideoPreview = GPUImageView(frame: self.view.bounds)
        view.insertSubview(captuerVideoPreview, at: 0)
        
        //创建组合滤镜
        let groupFilter = GPUImageFilterGroup()
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

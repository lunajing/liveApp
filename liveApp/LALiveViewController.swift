//
//  LALiveViewController.swift
//  liveApp
//
//  Created by luna on 2017/4/1.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import IJKMediaFramework

class LALiveViewController: UIViewController {
    var imageView = UIImageView()
    var player: IJKFFMoviePlayerController!
    var liveItem: LALiveItem!
    
    class func getInstance(item: LALiveItem) -> LALiveViewController {
        let vc = LALiveViewController()
        vc.liveItem = item
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        imageView.sd_setImage(with: URL(string: liveItem.creator.portrait), placeholderImage: nil)
        
        player = IJKFFMoviePlayerController(contentURLString: liveItem.stream_addr, with: nil)
        player.prepareToPlay()
        player.view.frame = view.bounds
        view.addSubview(player.view)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        player.stop()
        player.shutdown()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

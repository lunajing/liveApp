//
//  ViewController.swift
//  liveApp
//
//  Created by luna on 2017/3/30.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import SnapKit
import AFNetworking
import YYModel
import SDWebImage

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        buttonView()
    }
    
    func buttonView() {
        let v = UIView()
        view.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let button = UIButton()
        button.setTitle("我要看直播", for: .normal)
        v.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.left.right.top.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 120))
        }
        button.layer.cornerRadius = 60
        button.backgroundColor = UIColor.magenta
        button.addTarget(self, action: #selector(gotoLiveList), for: .touchUpInside)
        
        let button_ = UIButton()
        button_.setTitle("我要直播", for: .normal)
        v.addSubview(button_)
        button_.snp.makeConstraints { (make) in
            make.bottom.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 120))
            make.top.equalTo(button.snp.bottom).offset(30)
        }
        button_.layer.cornerRadius = 60
        button_.backgroundColor = UIColor.brown
        button_.addTarget(self, action: #selector(gotoCapture), for: .touchUpInside)
    }
    
    func gotoLiveList() {
        navigationController?.pushViewController(LALiveListViewController(), animated: true)
    }
    
    func gotoCapture() {
        navigationController?.pushViewController(LALiveShowingViewController(), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

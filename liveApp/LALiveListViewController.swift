//
//  LALiveListViewController.swift
//  liveApp
//
//  Created by luna on 2017/3/31.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit
import AFNetworking

class LALiveListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView = UITableView()
    var dataList = [LALiveItem]()
    
    let url = "http://116.211.167.106/api/live/aggregation?uid=133825214&interest=2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "直播列表"
        view.backgroundColor = UIColor.white
        configTableView()
        getLiveList(url: url)
        // Do any additional setup after loading the view.
    }
    
    func configTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LALiveListCell.self, forCellReuseIdentifier: "LALiveListCell")
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LALiveListCell", for: indexPath) as? LALiveListCell
        if cell == nil {
            cell = LALiveListCell(style: .default, reuseIdentifier: "LALiveListCell")
        }
        return cell!
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! LALiveListCell).configCell(withItem: dataList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(LALiveViewController.getInstance(item: dataList[indexPath.row]), animated: true)
    }
    
    func getLiveList(url: String) {
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.get(url, parameters: nil, progress: nil, success: { [weak self](task, response) in
            NSLog("\((response as! [String:Any])["lives"]!)")
            let lives = NSArray.yy_modelArray(with: LALiveItem.self, json: (response as! [String:Any])["lives"]!) as? [LALiveItem]
            if lives != nil {
                self?.dataList = lives!
                self?.tableView.reloadData()
            }
        }) { (task, error) in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class LALiveListCell: UITableViewCell {
    var nickLabel = UILabel()
    var coverImage = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.addSubview(nickLabel)
        nickLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(10)
            make.height.equalTo(16)
        }
        nickLabel.setContentCompressionResistancePriority(51, for: .vertical)
        
        contentView.addSubview(coverImage)
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true
        coverImage.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(10)
            make.top.equalTo(nickLabel.snp.bottom).offset(10)
            make.bottom.equalTo(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configCell(withItem item: LALiveItem) {
        nickLabel.text = item.creator.nick
        let url = URL(string: item.creator.portrait)
        coverImage.sd_setImage(with: url, placeholderImage: nil, options: .retryFailed)
    }
}

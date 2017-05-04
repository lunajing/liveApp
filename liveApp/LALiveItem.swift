//
//  LALiveItem.swift
//  liveApp
//
//  Created by luna on 2017/3/31.
//  Copyright © 2017年 aiztone. All rights reserved.
//

import UIKit

class LALiveItem: NSObject {
    var id = ""
    var city = ""
    var share_addr = ""
    var stream_addr = ""//直播流地址
    var online_users = 0
    var creator = LACreatorItem()
}

class LACreatorItem: NSObject {
    var id = 0
    var level = 0
    var gender = 0
    var nick = ""
    var portrait = ""
}

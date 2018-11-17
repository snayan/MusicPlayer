//
//  MPChannelData.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/15.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

struct MPChannelData: Decodable {
    
    struct Album: Decodable {
        var id: Int?
        var mid: String?
        var name: String?
        var title: String?
    }
    
    struct Singer: Decodable {
        var id: Int?
        var mid: String?
        var name: String?
        var title: String?
    }
    
    struct Song: Decodable {
        var id: Int?
        var name: String?
        var title: String?
        var status: Int?
        var url: String?
        var album: Album?
        var singer: [Singer]?
    }
    
    struct Data: Decodable {
        var nick: String?
        var headurl: String?
        var logo: String?
        var dissname: String?
        var visitnum: Int?
        var songnum: Int?
        var songlist: [Song]?
    }
    
    var cdlist: [Data]
    
    init() {
        cdlist = [Data()]
    }
    
    fileprivate(set) static var defaultData: MPChannelData.Data = {
        var d = MPChannelData()
        return d.cdlist[0]
    }()
    
    
}

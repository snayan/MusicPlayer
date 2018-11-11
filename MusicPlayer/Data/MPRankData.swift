//
//  MPRankData.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/11.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

struct MPRankData: Decodable {
    
    struct SongItem: Decodable {
        var singername: String
        var songname: String
    }
    
    struct ListItem: CellData {
        var id: Int?
        var listenCount: Int?
        var picUrl: String?
        var topTitle: String?
        var songList: [SongItem]?
        
    }
    
    struct Data: Decodable {
        var topList: [ListItem]
    }
    
    var code: Int
    var data: Data
    
    init() {
        code = 0
        data = Data(topList: [])
    }
    
    fileprivate(set) static var defaultData: [MPRankData.ListItem] = {
        let d = MPRankData()
        return d.data.topList
    }()
}

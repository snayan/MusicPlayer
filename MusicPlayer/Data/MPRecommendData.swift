//
//  MPBoxCollectionData.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/5.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

struct MPRecommendHomeData: Decodable {
    
    struct RadioData: CellData {
        var Ftitle: String?
        var picUrl: String?
        var radioid: Int?
    }
    
    struct SlideData: CellData {
        var id: Int?
        var linkUrl: String?
        var picUrl: String?
    }
    
    struct SongData: CellData {
        var id: String?
        var accessnum: Int?
        var album_pic_mid: String?
        var picUrl: String?
        var pic_mid: String?
        var songListAuthor: String?
        var songListDesc: String?
    }
    
    struct Data: Decodable {
        var radioList: [RadioData]?
        var slider: [SlideData]?
        var songList: [SongData]?
    }
    
    var code: Int
    var data: Data
    
    init() {
        code = 0
        data = Data()
    }
    
    static var defaultData: MPRecommendHomeData.Data = {
        var d = MPRecommendHomeData()
        d.data.radioList = (0...1).map{ _ in RadioData() }
        d.data.slider = [SlideData()]
        d.data.songList = (0...5).map{ _ in SongData() }
        return d.data
    }()

}

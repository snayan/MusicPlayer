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
        var picture: String? {
            get {
                guard let midValue = mid else {
                    return nil
                }
                return "https://y.gtimg.cn/music/photo_new/T002R300x300M000\(midValue).jpg"
            }
        }
    }
    
    struct Singer: Decodable {
        var id: Int?
        var mid: String?
        var name: String?
        var title: String?
        var picture: String? {
            get {
                guard let midValue = mid else {
                    return nil
                }
                return "https://y.gtimg.cn/music/photo_new/T001R300x300M000\(midValue).jpg"
            }
        }
    }
    
    struct Song: Decodable, Equatable {
        static func == (lhs: MPChannelData.Song, rhs: MPChannelData.Song) -> Bool {
            return lhs.mediaUrl == rhs.mediaUrl
        }
        
        var id: Int?
        var mid: String?
        var name: String?
        var title: String?
        var status: Int?
        var mediaUrl: String?
        var album: Album?
        var singer: [Singer]?
        var mediaPicture: String? {
            get {
                if let picture = album?.picture {
                    return picture
                } else if let singer = singer, singer.count > 0 {
                    return singer[0].picture
                } else {
                    return nil
                }
            }
        }
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

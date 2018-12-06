//
//  MPChannelAPI.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/17.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

fileprivate  struct MediaParam: Encodable {
    var guid: String = "0"
    var songmid: [String]?
    var songtype: [String] = []
    var uin: String = "0"
    var loginflag: Int = 0
    var platform: String = "23"
    var h5to: String = "speed"
}
fileprivate struct MediaData: Encodable {
    var module: String = "vkey.GetVkeyServer"
    var method: String = "CgiGetVkey"
    var param: MediaParam = MediaParam()
}
fileprivate struct PostData: Encodable {
    var req_0: MediaData = MediaData()
}

fileprivate struct ResSong: Decodable {
    var songmid: String
    var purl: String
    var vkey: String
    var filename: String
}

fileprivate struct ResMediaInfo: Decodable {
    var midurlinfo: [ResSong]
    var sip: [String]
}

fileprivate struct ResContent: Decodable {
    var data: ResMediaInfo
}


fileprivate struct ResData: Decodable {
    var req_0: ResContent
    func getMediaUrl(mid: String?, prefix: String?) -> String? {
        guard let mid = mid else {
            return nil
        }
        for midinfo in req_0.data.midurlinfo {
            if midinfo.purl != "" , midinfo.songmid == mid {
                return (prefix ?? "") + midinfo.purl
            }
        }
        return nil
    }
}

struct MPChannelAPI {
    
    func getChannelData(id: String, offset: Int , callback handler: @escaping (_: MPChannelData.Data?, _: Error?) -> Void) {
        
        var url = MPBaseURLSession.getURL(withPath: "qzone/fcg-bin/fcg_ucc_getcdinfo_byids_cp")
        
        url?.appendPathExtension("fcg")
        
        url = MPBaseURLSession.appendQuery(url: url, withQuery: "new_format=1&pic=500&disstid=\(id)&type=1&json=1&utf8=1&onlysong=0&picmid=1&nosign=1&song_begin=\(offset)&song_num=15")
        
        guard let invalidUrl = url else {
           return handler(nil, MPHttpError.URL(.InvalidURL))
        }
        
        var request = URLRequest(url: invalidUrl)
        request.setValue("https://y.qq.com/w/taoge.html?ADTAG=myqq&from=myqq&channel=10007100&id=\(id)", forHTTPHeaderField: "referer")
        
        MPBaseURLSession.getData(widthReqeust: request, completionHandler: { data, response, error in
            
            guard error != nil else {
                handler(nil, error)
                return
            }
            
            guard let data = data else {
                handler(nil, MPHttpError.Server(.NoResponseData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let res = try decoder.decode(MPChannelData.self, from: data)
                if res.cdlist.count == 1 {
                    handler(res.cdlist[0], nil)
                } else {
                    handler(nil, MPHttpError.Server(.NoResponseData))
                }
            } catch {
                handler(nil, error)
            }
            
        })
        
    }
    
    func getMediaUrl(songs: [MPChannelData.Song], callback handler: @escaping (_: [MPChannelData.Song]?, _: Error?) -> Void) {
        
        var data = PostData()
        data.req_0.param.songmid = songs.reduce([]) { result, song in
            var copy = Array(result!)
            if let mid = song.mid, song.mediaUrl == nil {
                copy.append(mid)
            }
            return copy
        }
        let encoder = JSONEncoder()
        
        let url = URL(string: "https://u.y.qq.com/cgi-bin/musicu.fcg")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? encoder.encode(data)
        
        MPBaseURLSession.getData(widthReqeust: request, completionHandler: { data, response, error in
            guard error != nil else {
                handler(nil, error)
                return
            }
            
            guard let data = data else {
                handler(nil, MPHttpError.Server(.NoResponseData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let res = try decoder.decode(ResData.self, from: data)
                var prefix: String = "https://dl.stream.qqmusic.qq.com/"
                for sip in res.req_0.data.sip {
                    if sip.count > 0 {
                        prefix = sip.replacingOccurrences(of: "http", with: "https")
                        break
                    }
                }
                if prefix.last != "/" {
                    prefix += "/"
                }
                let result: [MPChannelData.Song] = songs.map({ song in
                    if song.mediaUrl == nil {
                        var copy = song
                        copy.mediaUrl = res.getMediaUrl(mid: song.mid, prefix: prefix)
                        return copy
                    }
                    return song
                })
                handler(result, nil)
            } catch {
                handler(nil, error)
            }
        })
    }
}

//
//  MPChannelAPI.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/17.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

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
}

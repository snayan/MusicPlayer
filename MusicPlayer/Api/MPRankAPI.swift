//
//  MPRankAPI.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/11.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

struct MPRankAPI {
    
    func getRankData(callback handler: @escaping (_: [MPRankData.ListItem]?, _: Error?) -> Void) {
        
        var url = MPBaseURLSession.getURL(withPath: "v8/fcg-bin/fcg_myqq_toplist")
        
        url?.appendPathExtension("fcg")
        
        MPBaseURLSession.getData(withUrl: url!, completionHandler: { data, response, error in
            
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
                let res = try decoder.decode(MPRankData.self, from: data)
                handler(res.data.topList, nil)
            } catch {
                handler(nil, error)
            }
            
        })
        
    }
}

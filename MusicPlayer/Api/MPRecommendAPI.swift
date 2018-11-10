//
//  MPRecommendAPI.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/7.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

struct MPRecommendAPI {
    
    func getHomeData(callback handler: @escaping (_: MPRecommendHomeData?,_: Error?) -> Void) {
        
        var url = MPBaseURLSession.getURL(withPath: "musichall/fcgi-bin/fcg_yqqhomepagerecommend")
        
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
                let res = try decoder.decode(MPRecommendHomeData.self, from: data)
                handler(res, nil)
            } catch {
                handler(nil, error)
            }
            
        })
    }
}

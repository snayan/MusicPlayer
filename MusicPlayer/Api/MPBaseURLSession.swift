//
//  MPBaseURLSession.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/7.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

struct MPBaseURLSession {
    
    fileprivate static let extendParam = "g_tk=1586499349&uin=460040722&format=json&inCharset=utf-8&outCharset=utf-8&notice=0&platform=h5&needNewCode=1&_=1541588702379"
    
    static let baseUrl = "https://c.y.qq.com"
    
    static func getURL(withPath path: String, widthExtendPatam: Bool = true) -> URL? {
        guard path.count > 0 else {
            return nil
        }
        
        var fullpath: String
        if path.starts(with: "/") {
            fullpath = baseUrl + path
        } else {
            fullpath = baseUrl + "/" + path
        }
        if widthExtendPatam {
            fullpath += "?" + extendParam
        }
        return URL(string: fullpath)
    }
    
    static func getData(withUrl url: URL, completionHandler handler: @escaping (_: Data?, _: HTTPURLResponse?, _: Error?) -> Void) {

        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard error != nil else {
                handler(data, response as? HTTPURLResponse, MPHttpError.Client(.AnyReason))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    handler(data, response as? HTTPURLResponse, MPHttpError.Server(.NotAvailabel))
                    return
            }
            
            handler(data, response as? HTTPURLResponse, nil)
        })
        
        task.resume()
    }
    
    static func getJSON(widthUrl url: URL, completionHandler handler: @escaping (_: Data?, _: Error?) -> Void ) {
        
        getData(withUrl: url, completionHandler: { data, response, error in
            
            guard error != nil else {
                handler(nil, error)
                return
            }
            
            guard let mimeType = response?.mimeType, mimeType == "application/json" else {
                handler(nil, MPHttpError.Server(.InvalidMimeType))
                return
            }
            
            handler(data, nil)
            
        })
    }
    
    static func getImage(withUrl url: URL, completionHandler handler: @escaping (_: UIImage?, _: Error?) -> Void ) {
       
        getData(withUrl: url, completionHandler: { data, response, error in
            
            guard error != nil else {
                handler(nil, error)
                return
            }
            guard let mimeType = response?.mimeType, mimeType.hasPrefix("image") else {
                handler(nil, MPHttpError.Server(.InvalidMimeType))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                handler(nil, MPHttpError.Server(.AnyReason))
                return
            }
            
            handler(image, nil)
            
        })
    }
}

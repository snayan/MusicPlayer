//
//  UIImage.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/10.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func load(from src: String, loadhandler handler: @escaping (_: UIImage?, _: Error?) -> Void ) {
        
        let secureSrc = src.starts(with: "https") ? src : src.replacingOccurrences(of: "http", with: "https")
        guard let url = URL(string: secureSrc) else {
            handler(nil, MPHttpError.URL(.InvalidURL))
            return 
        }
        MPBaseURLSession.getImage(withUrl: url) { image, error in
            guard let image = image, error == nil else {
                handler(nil, MPHttpError.Server(.AnyReason))
                return
            }
            handler(image, nil)
        }
    }
    
    func loaded(from src: String) -> UIImage {
        type(of: self).load(from: src) { image, error in
           
            if error != nil , let image = image {
//                self = image
            }
            
        }
        return self
    }
}

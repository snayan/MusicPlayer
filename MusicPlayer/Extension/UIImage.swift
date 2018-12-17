//
//  UIImage.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/6.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    enum ErrorType: Error {
        case invalidURL
    }
    
    static func download(fromSrc src: String, completionHandler handler: @escaping (_: UIImage?, _: Error?) -> Void) {
        guard let url = URL.ATS(string: src) else {
            handler(nil, ErrorType.invalidURL)
            return
        }
        download(fromURL: url, completionHandler: handler)
    }
    
    static func download(fromURL url: URL, completionHandler handler: @escaping (_: UIImage?, _: Error?) -> Void) {
        MPBaseURLSession.getImage(withUrl: url, completionHandler: handler)
    }
    
    func resizedImage(_ size: CGSize) -> UIImage? {
        guard self.size != size else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizedImageWithinRect(_ size: CGSize) -> UIImage? {
        let widthFactor = self.size.width / size.width
        let heightFactor = self.size.height / size.height
        
        var resizeFactor = widthFactor
        if self.size.height > self.size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: self.size.width/resizeFactor, height: self.size.height/resizeFactor)
        let resized = resizedImage(newSize)
        return resized
    }

}

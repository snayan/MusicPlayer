//
//  UIImageView.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/8.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloaded(from src: String?, contentMode mode: UIView.ContentMode = .scaleAspectFit, useFallImage fall: UIImage? = nil ) -> Void {
        
        contentMode = mode
        
        guard let src = src else {
            self.image = fall
            return
        }
        
        guard let url = URL.ATS(string: src) else {
            self.image = fall
            return
        }
    
        MPBaseURLSession.getImage(withUrl: url) { image, error in
            guard let image = image, error == nil else {
                DispatchQueue.main.async() {
                    self.image = fall
                }
                return
            }
            DispatchQueue.main.async() {
                self.image = image
            }
        }
    }
}



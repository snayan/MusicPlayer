//
//  MPImageSlideshowDelegate.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/5.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

protocol MPImageSlideshowDelegate: class {
    func pageWillChanged(_ currentPage: Int) -> Bool
    func pageDidChanged(_ currentPage: Int) -> Void
}

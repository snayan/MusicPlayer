//
//  MPCollectionViewCell.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/6.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPImageSlideshowCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MPImageSlideshowCell"
    
    lazy var data: [UIImage] = {
        var imageViews: [UIImage] = []
        for i in 0..<5 {
            imageViews.append(UIImage(named: "slider\(i+1)")!)
        }
        return imageViews
    }()
    
    lazy var slideshow: MPImageSlideshowView = {
        let slideshow = MPImageSlideshowView()
        slideshow.interval = 5
        slideshow.data = self.data
        return slideshow
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        addSubview(slideshow)
        makeConstraints()
    }
    
    fileprivate func makeConstraints() {
        slideshow.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

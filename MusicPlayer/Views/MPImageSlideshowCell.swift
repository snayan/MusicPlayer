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
    
    var data: [String?]? {
        didSet {
            self.slideshow.data = filterData(from: data)
        }
    }
    
    lazy var slideshow: MPImageSlideshowView = {
        let slideshow = MPImageSlideshowView()
        slideshow.interval = 5
        slideshow.data = filterData(from: data)
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
    
    fileprivate func filterData(from data: [String?]?) -> [String] {
        var result: [String] = []
        if let data = data {
            for url in data {
                if url != nil {
                    result.append(url!)
                }
            }
        }
        return result
    }
}

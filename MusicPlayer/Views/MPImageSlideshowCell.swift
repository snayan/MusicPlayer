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
    
    var data: [MPRecommendHomeData.SlideData?]? {
        didSet {
            self.slideshow.data = filterData(from: data?.map { $0?.picUrl } )
        }
    }
    
    lazy var slideshow: MPImageSlideshowView = { [unowned self] in
        let slideshow = MPImageSlideshowView()
        slideshow.interval = 5
        slideshow.data = filterData(from: filterData(from: data?.map { $0?.picUrl } ))
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
    
    func getCurrentWebViewSrc() -> String? {
        let index = slideshow.currentPage
        if let currentData = data?[index] {
            return currentData.linkUrl
        }
        return nil
    }
    
    private func setup() {
        addSubview(slideshow)
        makeConstraints()
    }
    
    private func makeConstraints() {
        slideshow.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
    
    private func filterData(from data: [String?]?) -> [String] {
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

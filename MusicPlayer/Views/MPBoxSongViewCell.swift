//
//  MPSongCategoryViewCell.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/5.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

class MPBoxSongViewCell: UICollectionViewCell {

    static let reuseIdentifier = "MPBoxSongViewCell"
    
    var defaultImage = UIImage(named: "defaultSongPic")
    var data: CellData? {
        didSet {
            if let radioData = data as? MPRecommendHomeData.RadioData {
                imageCell.downloaded(from: radioData.picUrl , useFallImage: defaultImage)
                titleCell.text = radioData.Ftitle
            } else if let songData = data as? MPRecommendHomeData.SongData {
                imageCell.downloaded(from: songData.picUrl, useFallImage: defaultImage)
                titleCell.text = songData.songListDesc
            } else {
                imageCell.image = defaultImage
            }
        }
    }
    
    var imageCell = UIImageView()
    var titleCell: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
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
        addSubview(imageCell)
        addSubview(titleCell)
        backgroundColor = UIColor.white
        makeConstraints()
    }
    
    fileprivate func makeConstraints() {
        imageCell.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, 0, 46, 0))
        }
        titleCell.snp.makeConstraints{ make in
            make.top.equalTo(imageCell.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
    }
}

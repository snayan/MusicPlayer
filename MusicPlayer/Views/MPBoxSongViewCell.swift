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
                headsetIconCell.isHidden = true
            } else if let songData = data as? MPRecommendHomeData.SongData {
                imageCell.downloaded(from: songData.picUrl, useFallImage: defaultImage)
                titleCell.text = songData.songListDesc
                authorCell.text = songData.songListAuthor
                if let accessnum = songData.accessnum {
                    listenersCell.text = accessnum > 10000 ? "\(floorf(Float(accessnum) / 100)/100)万" : String(accessnum)
                }
            } else {
                imageCell.image = defaultImage
            }
        }
    }
    
    var imageCell = UIImageView()
    lazy var playIconCell: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        if let image = UIImage(named: "listSprit") {
            if let playIcon = image.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 48, height: 48)) {
                iconView.image = UIImage(cgImage: playIcon)
            }
        }
        return iconView
    }()
    lazy var headsetIconCell: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        if let image = UIImage(named: "listSprit") {
            if let playIcon = image.cgImage?.cropping(to: CGRect(x: 0, y: 100, width: 20, height: 20)) {
                iconView.image = UIImage(cgImage: playIcon)
            }
        }
        return iconView
    }()
    var titleCell: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    var authorCell: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    var listenersCell: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
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
        addSubview(authorCell)
        addSubview(playIconCell)
        addSubview(headsetIconCell)
        addSubview(listenersCell)
        backgroundColor = UIColor.white
        makeConstraints()
    }
    
    fileprivate func makeConstraints() {
        imageCell.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 0, left: 0, bottom: 46, right: 0))
        }
        titleCell.snp.makeConstraints{ make in
            make.top.equalTo(imageCell.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        authorCell.snp.makeConstraints{ make in
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        playIconCell.snp.makeConstraints{ make in
            make.right.bottom.equalTo(imageCell).offset(-5)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        headsetIconCell.snp.makeConstraints{ make in
            make.left.equalTo(imageCell).offset(5)
            make.bottom.equalTo(imageCell).offset(-7)
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        listenersCell.snp.makeConstraints{ make in
            make.left.equalTo(headsetIconCell.snp.right).offset(5)
            make.bottom.equalTo(imageCell).offset(-5)
        }
    }
}

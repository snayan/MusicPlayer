//
//  MPRankTableViewCell.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/11.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPRankTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "MPRankTableViewCell"
    
    var data = MPRankData.ListItem() {
        didSet {
            imageCell.downloaded(from: data.picUrl, useFallImage: UIImage(named: "defaultSongPic"))
            titleCell.text = data.topTitle
            data.songList?.enumerated().forEach() { index, song in
                if index < songCell.count {
                    let text = NSMutableAttributedString(string: "\(index + 1)  \(song.songname) - \(song.singername)")
                    text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(2, 2 + song.songname.count))
                    songCell[index].attributedText = text
                }
            }
            let listenCount = data.listenCount ?? 0
            listenersCell.text = listenCount > 10000 ? "\(floorf(Float(listenCount/100))/100)万" : String(listenCount)
        }
    }
    var cellView: UIView = UIView()
    var imageCell: UIImageView = UIImageView(image: UIImage(named: "defaultSongPic"))
    lazy var titleCell: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    var listenersCell: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 9)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    lazy var songCell: [UILabel] = {
        return (0...2).map(){_ in
            let label = UILabel()
            label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 1
            label.sizeToFit()
            return label
        }
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "bgColor")
        cellView.backgroundColor = UIColor.white
        contentView.addSubview(cellView)
        setup()
    }
    
    fileprivate func setup() {
        cellView.addSubview(imageCell)
        cellView.addSubview(titleCell)
        cellView.addSubview(headsetIconCell)
        cellView.addSubview(listenersCell)
        songCell.forEach(){cellView.addSubview($0)}
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func makeConstraints() {
        cellView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
        }
        imageCell.snp.makeConstraints{ make in
            make.left.top.equalToSuperview()
            make.width.equalTo(cellView.snp.height)
            make.height.equalTo(cellView.snp.height)
        }
        titleCell.snp.makeConstraints{ make in
            make.left.equalTo(imageCell.snp.right).offset(15)
            make.top.equalTo(cellView).offset(8)
            make.right.equalTo(cellView).offset(-5)
        }
        songCell.enumerated().forEach(){ index, label in
            label.snp.makeConstraints(){ make in
                if index == 0 {
                    make.top.equalTo(titleCell.snp.bottom).offset(5)
                } else {
                    make.top.equalTo(songCell[index - 1].snp.bottom).offset(5)
                }
                make.left.equalTo(imageCell.snp.right).offset(15)
                make.right.equalTo(cellView).offset(-5)
            }
        }
        headsetIconCell.snp.makeConstraints{ make in
            make.left.equalTo(imageCell).offset(5)
            make.bottom.equalTo(imageCell).offset(-7)
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        listenersCell.snp.makeConstraints{ make in
            make.left.equalTo(headsetIconCell.snp.right).offset(3)
            make.top.equalTo(headsetIconCell)
        }
    }

}

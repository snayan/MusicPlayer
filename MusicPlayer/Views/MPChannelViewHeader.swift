//
//  MPChannelTableHeaderView.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/15.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPChannelViewHeader: UIView {
    
    var albumImageUrl: String? {
        didSet {
            albumImageView.downloaded(from: albumImageUrl)
        }
    }
    var title: String? {
        didSet {
            titleView.text = title
        }
    }
    var nickName: String? {
        didSet {
            nickNameView.text = nickName
        }
    }
    var nickIcon: String? {
        didSet {
            nickIconView.downloaded(from: nickIcon, useFallImage: UIImage(named: "defaultAvatar"))
        }
    }
    var playCount: Int? {
        didSet {
            if let playCount = playCount {
                let text = playCount > 10000 ? "\(floorf(Float(playCount) / 100)/100)万" : String(playCount)
                playCountView.text = "播放量：" + text
            } else {
                playCountView.text = ""
            }
        }
    }
    
    lazy fileprivate var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 16, y: 17, width: 125, height: 125)
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy fileprivate var nickIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "defaultAvatar")
        return imageView
    }()
    lazy fileprivate var titleView: UILabel = { self.createLable(fontSize: 18, numberOfLines: 2) }()
    lazy fileprivate var nickNameView = { self.createLable(fontSize: 14) }()
    lazy fileprivate var playCountView = { self.createLable(fontSize: 12) }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    fileprivate func createLable(fontSize: Float, numberOfLines lines: Int = 1) -> UILabel {
        let lable = UILabel()
        lable.textColor = UIColor.white
        lable.numberOfLines = lines
        lable.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        lable.sizeToFit()
        return lable
    }
    
    fileprivate func setup() {
        addSubview(albumImageView)
        addSubview(titleView)
        addSubview(nickIconView)
        addSubview(nickNameView)
        addSubview(playCountView)
        makeConstraints()
        backgroundColor = UIColor(named: "themeLightColor")
    }
    
    fileprivate func makeConstraints() {
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(34)
            make.left.equalTo(albumImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
        }
        nickIconView.snp.makeConstraints{ make in
            make.left.equalTo(titleView)
            make.top.equalTo(titleView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        nickNameView.snp.makeConstraints{ make in
            make.left.equalTo(nickIconView.snp.right).offset(8)
            make.centerY.equalTo(nickIconView)
        }
        playCountView.snp.makeConstraints{ make in
            make.left.equalTo(titleView)
            make.top.equalTo(nickIconView.snp.bottom).offset(8)
        }
    }
}

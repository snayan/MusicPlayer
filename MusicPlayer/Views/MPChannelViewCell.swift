//
//  MPChannelViewCell.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/15.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPChannelViewCell: UITableViewCell {

    static let reuseIdentifiter = "MPChannelViewCell"
    
    var data: MPChannelData.Song? {
        didSet {
            var subText: [String] = []
            if let count = data?.singer?.count, count > 0, let singerName = data?.singer?[0].name {
                subText.append(singerName)
            }
            if let album = data?.album, let ablumtitle = album.title {
                subText.append(ablumtitle)
            }
            title.text = data?.title
            subTitle.text = subText.joined(separator: " · ")
        }
    }
    
    lazy var title: UILabel = {
        createLabel(fontSize: 16, fontColor: UIColor.black)
    }()
    
    lazy var subTitle: UILabel = {
        createLabel(fontSize: 12, fontColor: UIColor.gray)
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(title)
        contentView.addSubview(subTitle)
        selectionStyle = .none
        makeConstraints()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            title.textColor = UIColor(named: "themeLightColor")
            subTitle.textColor = UIColor(named: "themeLightColor")
        } else {
            title.textColor = UIColor.black
            subTitle.textColor = UIColor.gray
        }
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func createLabel(fontSize size: Float, fontColor color: UIColor, fontWeight weight: UIFont.Weight = UIFont.Weight.regular) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(size), weight: weight)
        label.textColor = color
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }
    
    fileprivate func makeConstraints() {
        title.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }
        subTitle.snp.makeConstraints{ make in
            make.left.right.equalTo(title)
            make.top.equalTo(title.snp.bottom).offset(2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

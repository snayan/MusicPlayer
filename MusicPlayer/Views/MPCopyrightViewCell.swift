//
//  MPCopyrightViewCell.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/7.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPCopyrightViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MPCopyrightViewCell"
    
    let h5Label: UILabel = {
        let label = UILabel()
        label.text = "查看移动网页版"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "Copyright © 1998 - 2018 Tencent. All Rights Reserved."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return label
    }()
    let contactLabel: UILabel = {
        let label = UILabel()
        label.text = "联系电话：0755-86013388 QQ群：55209235"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return label
    }()
    let footIcon: UIImageView = UIImageView(image: UIImage(named: "QQMusicBlack")!)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        addSubview(h5Label)
        addSubview(footIcon)
        addSubview(copyrightLabel)
        addSubview(contactLabel)
        makeConstiants()
    }
    
    fileprivate func makeConstiants() {
        h5Label.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview()
        }
        footIcon.snp.makeConstraints{ make in
            make.top.equalTo(h5Label.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        copyrightLabel.snp.makeConstraints{ make in
            make.top.equalTo(footIcon.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        contactLabel.snp.makeConstraints{ make in
            make.top.equalTo(copyrightLabel.snp.bottom).offset(0)
            make.left.right.equalToSuperview()
        }
    }
}

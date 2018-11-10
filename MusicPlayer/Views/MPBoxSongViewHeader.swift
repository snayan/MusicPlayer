//
//  MPBoxSongViewHeader.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/6.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

class MPBoxSongViewHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "MPBoxSongViewHeader"
    
    let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        addSubview(label)
        label.font = UIFont.systemFont(ofSize: 16)
        label.snp.makeConstraints{ make in
            make.bottom.equalToSuperview().offset(-11)
            make.left.equalToSuperview().offset(10)
        }
    }
}

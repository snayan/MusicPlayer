//
//  MPPlayContentView.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/19.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPPlayContentView: UIView {
    
    var singerPicture: String? {
        didSet {
            songImageView.downloaded(from: singerPicture, useFallImage: UIImage(named: "defaultSongPic"))
        }
    }
    
    lazy var paddingLeft: CGFloat = { frame.width * 0.08 }()
    lazy var paddingTop: CGFloat = { paddingLeft * 1.6 }()
    lazy var songImageView: UIImageView = { [unowned self] in
        let view = UIImageView(image: UIImage(named: "defaultSongPic"))
        view.clipsToBounds = true
        return view
    }()
    lazy var songImageBackView: UIView = { [unowned self] in
        var view = UIView()
        view.backgroundColor = UIColor(named: "themeLightColor")
        view.clipsToBounds = true
        return view
    }()
    lazy var timeSlider: UISlider = { [unowned self] in
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = false
        slider.thumbTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor(named: "themeColor")
        slider.maximumTrackTintColor = UIColor(named: "bgColor")
        return slider
    }()
    lazy var currentSongTime: UILabel = { createLabel(fontSize: 12, fontColor: timeSlider.minimumTrackTintColor) }()
    lazy var totalSongTime: UILabel = { createLabel(fontSize: 12, fontColor: timeSlider.maximumTrackTintColor) }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(songImageBackView)
        addSubview(songImageView)
        addSubview(timeSlider)
        addSubview(currentSongTime)
        addSubview(totalSongTime)
        makeConstraints()
        currentSongTime.text = String(timeSlider.minimumValue)
        totalSongTime.text = String(timeSlider.maximumValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        songImageBackView.layer.cornerRadius = songImageBackView.frame.height/2
        songImageView.layer.cornerRadius = songImageView.frame.height/2
    }
    
    
    fileprivate func makeConstraints() {
        songImageBackView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(paddingTop)
            make.left.equalToSuperview().offset(paddingLeft)
            make.right.equalToSuperview().offset(-paddingLeft)
            make.height.equalTo(songImageBackView.snp.width)

        }
        songImageView.snp.makeConstraints{ make in
            make.edges.equalTo(songImageBackView).inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
        timeSlider.snp.makeConstraints{ make in
            make.top.equalTo(songImageBackView.snp.bottom).offset(paddingTop)
            make.left.right.equalTo(songImageBackView)
        }
        currentSongTime.snp.makeConstraints{ make in
            make.left.equalTo(timeSlider)
            make.top.equalTo(timeSlider.snp.bottom).offset(0)
        }
        totalSongTime.snp.makeConstraints{ make in
            make.right.equalTo(timeSlider)
            make.top.equalTo(currentSongTime)
        }
    }
    
    fileprivate func createLabel(fontSize size: Float, fontColor color: UIColor?) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(size))
        label.textColor = color
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }
    
}

//
//  MPPlayViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/17.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPPlayViewController: UINavigationController {

    convenience init() {
        self.init(rootViewController: MPPlayContentViewController(data: nil))
        self.modalPresentationStyle = .overFullScreen
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(named: "themeColor")
        navigationBar.tintColor = UIColor.white
    }

}

fileprivate class MPPlayContentViewController: UIViewController {
    
    var data: String?
    var backgroundScale: Float = 1.2

    lazy var song: UILabel = { createLabel(fontSize: 16, fontColor: UIColor.white) }()
    lazy var singer: UILabel = { createLabel(fontSize: 12, fontColor: UIColor.white) }()
    lazy var backgroundImage: UIImageView = UIImageView()
    
    lazy var titleView: UIView = { [unowned self] in
        let view = UIView()
        view.addSubview(song)
        view.addSubview(singer)
        view.backgroundColor = UIColor.red
        return view
        }()
    lazy var backgroundView: UIView = { [unowned self] in
        var view = UIView()
        view.backgroundColor = UIColor.clear
        view.frame = self.view.bounds
        
        // 设置backgroundImage
        let parentViewWidth = self.view.frame.width
        let parentViewHeight = self.view.frame.height
        let maxValue = max(parentViewWidth, parentViewHeight) * CGFloat(self.backgroundScale)
        backgroundImage.bounds.size = CGSize(width: maxValue, height: maxValue)
        backgroundImage.frame.origin = CGPoint(x: -(maxValue - parentViewWidth)/2, y: -(maxValue - parentViewHeight)/2)
        
        // 设置blur view
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(backgroundImage, at: 0)
        view.addSubview(blurEffectView)
        return view
    }()
    lazy var contentView: MPPlayContentView = { [unowned self] in MPPlayContentView(frame: self.view.bounds) }()
    
    init(data: String?) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        song.text = "歌曲名称"
        singer.text = "歌手"
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapDismiss))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.addSubview(contentView)
        view.insertSubview(backgroundView, belowSubview: contentView)
        makeConstriants()
        backgroundImage.downloaded(from: "https://p.qpic.cn/music_cover/1Fr9IFMhWDPeUzWKVEjn3QTL2eX2QziaJmaL0ZAmsvtW71ic9IDUoYzg/600?n=1", contentMode: .scaleAspectFill)
    }
    
    fileprivate func createLabel(fontSize size: Float, fontColor color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(size))
        label.textColor = color
        label.numberOfLines = 1
        label.sizeToFit()
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        return label
    }
    
    fileprivate func makeConstriants() {
        song.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6)
        }
        singer.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(song.snp.bottom)
        }
    }
    
    @objc fileprivate func tapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

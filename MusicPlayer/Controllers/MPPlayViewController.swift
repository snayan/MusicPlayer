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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }

}

fileprivate class MPPlayContentViewController: UIViewController {
    
    var data: String?
    
    lazy var titleView: UIView = { [unowned self] in
        let view = UIView()
        view.addSubview(song)
        view.addSubview(singer)
        view.backgroundColor = UIColor.red
        return view
    }()
    lazy var song: UILabel = { createLabel(fontSize: 16, fontColor: UIColor.white) }()
    lazy var singer: UILabel = { createLabel(fontSize: 12, fontColor: UIColor.white) }()
    
    init(data: String?) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        song.text = "歌曲名称"
        singer.text = "歌手"
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapDismiss))
        makeConstriants()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

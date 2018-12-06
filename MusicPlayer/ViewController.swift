//
//  ViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/10/31.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UITabBarController {
    
    var playingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restorationIdentifier = "MainTabBarController"
        self.view.backgroundColor = UIColor(named: "bgColor")
        setupPlayingImage()
        setupControllers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(self.selectedIndex, forKey: "selectedIndex")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if coder.containsValue(forKey: "selectedIndex") {
            self.selectedIndex = coder.decodeInteger(forKey: "selectedIndex")
        }
    }
    
    private func setupPlayingImage() {
        let height = tabBar.frame.height - 8
        let tabBarWidth = tabBar.frame.width
        playingImageView = UIImageView()
        playingImageView.frame = CGRect(x: (tabBarWidth - height)/2 , y: (tabBar.frame.height - height)/2, width: height, height: height)
        playingImageView.backgroundColor = UIColor.red
        playingImageView.layer.cornerRadius = height/2
        playingImageView.clipsToBounds = true
        playingImageView.downloaded(from: PlayerManager.shared.currentSong?.album?.picture, useFallImage: UIImage(named: "defaultSongPic"))
        tabBar.addSubview(playingImageView)
    }
    
    private func setupControllers() {
        let recommendController = MPTabBarChildViewController(type: .Recommend)
        let rankController = MPTabBarChildViewController(type: .Rank)
        let playingController = UIViewController()
        viewControllers = [recommendController, playingController, rankController]
        selectedIndex = 0
        delegate = self
    }
    
}

extension ViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController === viewControllers?[1] {
            let vc =  MPPlayViewController(data: PlayerManager.shared.currentSong, autoPlay: false)
            self.present(vc, animated: true, completion: nil)
            return false
        }
        return true
    }
}


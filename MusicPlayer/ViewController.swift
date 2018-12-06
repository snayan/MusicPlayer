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
    
    private var animator: UIViewPropertyAnimator?
    private var playingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restorationIdentifier = "MainTabBarController"
        self.view.backgroundColor = UIColor(named: "bgColor")
        setupPlayingImage()
        setupControllers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observePlayerNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
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
        let height = tabBar.frame.height + 8
        let tabBarWidth = tabBar.frame.width
        playingImageView = UIImageView()
        playingImageView.frame = CGRect(x: (tabBarWidth - height)/2 , y: (tabBar.frame.height - height)-2, width: height, height: height)
        playingImageView.backgroundColor = UIColor.red
        playingImageView.layer.cornerRadius = height/2
        playingImageView.clipsToBounds = true
        playingImageView.downloaded(from: PlayerManager.shared.currentSong?.mediaPicture, useFallImage: UIImage(named: "defaultSongPic"))
        tabBar.addSubview(playingImageView)
        if PlayerManager.shared.status == .playing {
            startRotateImage()
        } else {
            stopRotateImage()
        }
    }
    
    private func setupControllers() {
        let recommendController = MPTabBarChildViewController(type: .Recommend)
        let rankController = MPTabBarChildViewController(type: .Rank)
        let playingController = UIViewController()
        viewControllers = [recommendController, playingController, rankController]
        selectedIndex = 0
        delegate = self
    }
    
    private func startRotateImage() {
        if animator == nil {
            animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 30, delay: 0, options: .curveLinear, animations: {
                self.playingImageView.transform = self.playingImageView.transform.rotated(by: CGFloat.pi)
            }, completion: { finalPosition in
                self.animator = nil
                self.startRotateImage()
            })
        } else {
            animator!.startAnimation()
        }
    }
    
    private func stopRotateImage() {
        animator?.pauseAnimation()
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

extension ViewController {
    
    func observePlayerNotification() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(ViewController.playerSongChanged), name: Notification.Name.player.songChanged, object: nil)
        center.addObserver(self, selector: #selector(ViewController.playerStatusChanged), name: Notification.Name.player.statusChanged, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func playerSongChanged(notification: Notification) {
        let userInfo = notification.userInfo
        let song = userInfo?["value"] as? Song
        DispatchQueue.main.async {
            self.playingImageView.downloaded(from: song?.mediaPicture, useFallImage: UIImage(named: "defaultSongPic"))
        }
    }
    
    @objc private func playerStatusChanged(notification: Notification) {
        let userInfo = notification.userInfo
        let status = userInfo?["value"] as? PlayerManager.Status
        DispatchQueue.main.async {
            status == .playing ? self.startRotateImage() : self.stopRotateImage()
        }
    }
}

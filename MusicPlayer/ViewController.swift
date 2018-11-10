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
    
    let mpRecommendController = MPTabBarChildViewController(type: MPTabBarItemEnum.Recommend)
    let mpRankController = MPTabBarChildViewController(type: MPTabBarItemEnum.Rank)
    let mpSearchController = MPTabBarChildViewController(type: MPTabBarItemEnum.Search)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restorationIdentifier = "MainTabBarController"
        self.view.backgroundColor = UIColor(named: "bgColor")
        self.viewControllers = [mpRecommendController, mpRankController, mpSearchController]
        self.selectedIndex = 0
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


}


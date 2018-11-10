//
//  MPTabbarChildViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/1.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

class MPTabBarChildViewController: UINavigationController {
    
    convenience init (type tabBarItem: MPTabBarItemEnum) {
        
        self.init(rootViewController: tabBarItem.getTabBarViewController())
        self.tabBarItem = UITabBarItem(title: tabBarItem.rawValue, image: tabBarItem.getTabBarIcon(), selectedImage: nil)
        self.navigationBar.backgroundColor = UIColor(named: "themeColor")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

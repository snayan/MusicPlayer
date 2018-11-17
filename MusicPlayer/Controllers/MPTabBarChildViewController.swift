//
//  MPTabbarChildViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/1.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import Hero

class MPTabBarChildViewController: UINavigationController {
    
    fileprivate let heroTransition = HeroTransition()
    
    convenience init (type tabBarItem: MPTabBarItemEnum) {
        self.init(rootViewController: tabBarItem.getTabBarViewController())
        self.tabBarItem = UITabBarItem(title: tabBarItem.rawValue, image: tabBarItem.getTabBarIcon(), selectedImage: nil)
        self.navigationBar.barTintColor = UIColor(named: "themeColor")
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.isTranslucent = false
        self.delegate = self
        self.hero.navigationAnimationType = .autoReverse(presenting: .slide(direction: .left))
    }

}

extension MPTabBarChildViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return heroTransition.navigationController(navigationController, interactionControllerFor: animationController)

    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return heroTransition.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}

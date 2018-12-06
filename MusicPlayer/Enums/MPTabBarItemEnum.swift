//
//  MPTabBarEnum.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/2.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit

enum MPTabBarItemEnum: String {
    case Recommend = "推荐"
    case Rank = "排行榜"
    case Playing = "播放中"
    
    func getTabBarIcon() -> UIImage {
        var iconName: String
        switch self {
        case .Recommend:
            iconName = "RecommendIcon"
        case .Rank:
            iconName = "RankIcon"
            
        case .Playing:
            iconName = "SearchIcon"
        }
        return UIImage(named: iconName)!
    }
    
    func getTabBarViewController() -> UIViewController {
        var controller: UIViewController
        switch self {
        case .Recommend:
            controller = MPRecommendViewController()
        case .Rank:
            controller = MPRankViewController()
        case .Playing:
            controller = MPSearchViewController()
        }
        controller.navigationItem.title = self.rawValue
        controller.navigationItem.titleView = UIImageView(image: UIImage(named: "QQMusicWhite"), highlightedImage: nil)
        return controller
    }
}


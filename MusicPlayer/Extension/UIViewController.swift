//
//  UIViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/5.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlter(title: String?, message: String?, configurateAction configuration: (() -> [UIAlertAction])?, completion handler: (() -> Void)?) {
        let alterController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let configuration = configuration {
            let actions = configuration()
            for action in actions {
                alterController.addAction(action)
            }
        }
        DispatchQueue.main.async {
            self.present(alterController, animated: true, completion: handler)
        }
    }
    
    func showRequestErrorAlter(error: Error?, buttonHandler handler: (() -> Void)?) {
        let configurate = { () -> [UIAlertAction] in
            return [UIAlertAction(title: "重试", style: .default, handler: { _ in
                if let handler = handler {
                    handler()
                }
            })]
        }
        showAlter(title: "网络请求失败", message: error?.localizedDescription ?? "请检查你的网络，然后重试一次吧", configurateAction: configurate, completion: nil)
    }
    
    func showRequestErrorAlter(message: String?, buttonHandler handler: (() -> Void)?) {
        let configurate = { () -> [UIAlertAction] in
            return [UIAlertAction(title: "重试", style: .default, handler: { _ in
                if let handler = handler {
                    handler()
                }
            })]
        }
        showAlter(title: "网络请求失败", message: message ?? "请检查你的网络，然后重试一次吧", configurateAction: configurate, completion: nil)
    }
    
    func showPlayErrorAlter(error: Error?, buttonHandler handler: (() -> Void)?) {
        let configurate = { () -> [UIAlertAction] in
            return [UIAlertAction(title: "好吧", style: .cancel, handler: { _ in
                if let handler = handler {
                    handler()
                }
            })]
        }
        showAlter(title: "播放失败", message: error?.localizedDescription ?? "歌曲播放失败，请关闭后重试吧", configurateAction: configurate, completion: nil)
    }
    
    func showErrorSongAlter(buttonHandler handler: (() -> Void)?) {
        let configurate = { () -> [UIAlertAction] in
            return [UIAlertAction(title: "好吧", style: .cancel, handler: { _ in
                if let handler = handler {
                    handler()
                }
            })]
        }
        showAlter(title: "播放失败", message: "歌曲信息缺失，无法播放", configurateAction: configurate, completion: nil)
    }
}

//
//  MPRankViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/3.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPRankViewController: UITableViewController {
    
    let api = MPRankAPI()
    var data = MPRankData.defaultData {
        didSet {
            // data 改变了，更新页面上的值
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    convenience init() {
        self.init(style: .plain)
        tableView.allowsMultipleSelection = false
        tableView.backgroundColor = UIColor(named: "bgColor")
        tableView.separatorStyle = .none
        tableView.register(MPRankTableViewCell.self, forCellReuseIdentifier: MPRankTableViewCell.reuseIdentifier)
    }
    
    override func viewDidLoad() {
        requestData()
    }
    
    fileprivate func requestData() {
        showLoading(true)
        api.getRankData { [unowned self] data, error in
            self.showLoading(false)
            guard error == nil else {
                // toast 提示错误
                self.showRequestErrorAlter(error: error, buttonHandler: nil)
                return
            }
            guard let pageData = data else {
                // toast 提示错误
                self.showRequestErrorAlter(message: "请求排行榜数据失败", buttonHandler: nil)
                return
            }
            self.data = pageData
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MPRankTableViewCell.reuseIdentifier) as! MPRankTableViewCell
        if indexPath.row < data.count {
            cell.data = data[indexPath.row]
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  CGFloat(110)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showAlter(title: "开发中", message: "功能正在开发中，敬请期待", configurateAction: {
            return [UIAlertAction(title: "加油", style: .cancel, handler: nil)]
        }, completion: nil)
    }
}

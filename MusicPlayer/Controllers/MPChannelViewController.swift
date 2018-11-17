//
//  MPChannelViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/12.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPChannelViewController: UITableViewController {
    
    var id: String
    var offset: Int = 0
    var api: MPChannelAPI = MPChannelAPI()
    var data: MPChannelData.Data? {
        didSet {
            setHeaderData()
            tableView.reloadData()
        }
    }
    
    lazy var headerView: MPChannelViewHeader = {
       let view = MPChannelViewHeader()
        view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 160)
        return view
    }()
    
    init(id: String, data: MPChannelData.Data?) {
        self.id = id
        self.data = data
        super.init(style: .plain)
        navigationItem.title = "歌单"
        tableView.register(MPChannelViewCell.self, forCellReuseIdentifier: MPChannelViewCell.reuseIdentifiter)
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        //        tableView.allowsSelection = false
        setHeaderData()
        requestData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func requestData() {
        api.getChannelData(id: id, offset: offset) { data, error in
            
            guard error == nil else {
                // toast 提示错误
                return
            }
            
            guard let pageData = data else {
                // toast 提示错误
                return
            }
            
            DispatchQueue.main.async {
                self.data = pageData
            }
        }
    }
    
    fileprivate func setHeaderData() {
        if let data = data {
            headerView.albumImageUrl = data.logo
            headerView.title = data.dissname
            headerView.nickIcon = data.headurl
            headerView.nickName = data.nick
            headerView.playCount = data.visitnum
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.songlist?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MPChannelViewCell.reuseIdentifiter, for: indexPath)
        if let mpChannelCell = cell as? MPChannelViewCell {
            mpChannelCell.data = data?.songlist?[indexPath.row]
            return mpChannelCell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(62)
    }

}



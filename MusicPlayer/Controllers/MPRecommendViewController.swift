//
//  MPRecommendViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/3.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPRecommendViewController: UICollectionViewController {
    
    let api = MPRecommendAPI()
    var data = MPRecommendHomeData.defaultData {
        didSet {
            // data 改变了，更新页面上的值
            //            print(data)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(10)
        layout.minimumInteritemSpacing = CGFloat(10)
        layout.scrollDirection = .vertical
        self.init(collectionViewLayout: layout)
        requestData()
        setup()
    }
    
    fileprivate func requestData() {
        api.getHomeData { data, error in
            
            guard error == nil else {
                // toast 提示错误
                return
            }
            
            guard let pageData = data else {
                // toast 提示错误
                return
            }
            
            self.data = pageData.data
        }
    }
    
    fileprivate func setup() {
        if let collectionView = collectionView {
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor(named: "bgColor")
            collectionView.isPrefetchingEnabled = true
            collectionView.register(MPImageSlideshowCell.self, forCellWithReuseIdentifier: MPImageSlideshowCell.reuseIdentifier)
            collectionView.register(MPBoxSongViewCell.self, forCellWithReuseIdentifier: MPBoxSongViewCell.reuseIdentifier)
            collectionView.register(MPCopyrightViewCell.self, forCellWithReuseIdentifier: MPCopyrightViewCell.reuseIdentifier)
            collectionView.register(MPBoxSongViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MPBoxSongViewHeader.reuseIdentifier)
            collectionView.register(MPCollectionEmptyCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MPCollectionEmptyCell.reuseIdentifier)
        }
    }
    
    fileprivate func getCellData(at indexPath: IndexPath) -> CellData? {
        guard isSongSection(at: indexPath)  else {
            return nil
        }
        if indexPath.section == 1 {
            // radio data
            return data.radioList?[indexPath.item]
            
        } else if indexPath.section == 2 {
            // song data
            return data.songList?[indexPath.item]
            
        } else {
            return nil
        }
    }
    
    fileprivate func isHeader(at indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(item: 0, section: 0)
    }
    
    fileprivate func isHeader(at section: Int) -> Bool {
        return section == 0
    }
    
    fileprivate func isFooter(at indexPath: IndexPath) -> Bool {
        return indexPath == IndexPath(item: 0, section: 3)
    }
    
    fileprivate func isFooter(at section: Int) -> Bool {
        return section == 3
    }
    
    fileprivate func isSongSection(at indexPath: IndexPath) -> Bool {
        return !isHeader(at: indexPath) && !isFooter(at: indexPath)
    }
    
    fileprivate func isSongSection(at section: Int) -> Bool {
        return !isHeader(at: section) && !isFooter(at: section)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var items: Int = 0
        switch section {
        case 0:
            items = 1
        case 1:
            items = data.radioList?.count ?? 0
        case 2:
            items = data.songList?.count ?? 0
        case 3:
            items = 1
        default:
            items = 0
        }
        return items
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isHeader(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPImageSlideshowCell.reuseIdentifier, for: indexPath) as! MPImageSlideshowCell
            
            cell.setNeedsLayout()
            return cell
        } else if isSongSection(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPBoxSongViewCell.reuseIdentifier, for: indexPath) as! MPBoxSongViewCell
            cell.data = getCellData(at: indexPath)
            cell.setNeedsLayout()
            return cell
        } else if isFooter(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPCopyrightViewCell.reuseIdentifier, for: indexPath)
            cell.setNeedsLayout()
            return cell
        } else {
            fatalError("section 无效")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if isSongSection(at: indexPath) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MPBoxSongViewHeader.reuseIdentifier, for: indexPath) as! MPBoxSongViewHeader
            header.label.text = indexPath == IndexPath(item: 0, section: 1) ? "电台" : "热门歌单"
            header.setNeedsLayout()
            return header
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MPCollectionEmptyCell.reuseIdentifier, for: indexPath)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isHeader(at: indexPath){
            let header = cell as! MPImageSlideshowCell
            header.slideshow.setTimerIfNeed()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isHeader(at: indexPath) {
            let header = cell as! MPImageSlideshowCell
            header.slideshow.inValidateTimer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize.zero
        }
        
        if isHeader(at: indexPath) {
            return CGSize(width: width, height: 150)
        } else if isSongSection(at: indexPath) {
            let cellWidth = (width - layout.minimumInteritemSpacing * 3)/2
            return CGSize(width: cellWidth, height: cellWidth + 46)
        } else if isFooter(at: indexPath) {
            return CGSize(width: width, height: 134)
        } else {
            return CGSize.zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if isSongSection(at: section) {
            return CGSize(width: collectionView.frame.size.width, height: 50)
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let minimumInteritemSpacing = layout?.minimumInteritemSpacing ?? 0
        if isSongSection(at: section) {
            return UIEdgeInsets(top: 0, left: minimumInteritemSpacing, bottom: 0, right: minimumInteritemSpacing)
        } else {
            return UIEdgeInsets.zero
        }
    }
    
}

extension MPRecommendViewController: UICollectionViewDelegateFlowLayout {
    
}

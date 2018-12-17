//
//  LocaleStore.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/16.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import UIKit

struct LocalStore {
    static private let documentDirectory = getDirectory(for: .documentDirectory)
    static private let musicDirectory = getDirectory(for: .musicDirectory)
    static private let cacheDirectory = getDirectory(for: .cachesDirectory)
    
    static private func getDirectory(for type: FileManager.SearchPathDirectory) -> URL {
        return try! FileManager.default.url(for: type, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    static func storeCacheImage(_ image: UIImage, fileName name: String) -> URL? {
        guard let data = image.pngData() else {
            return nil
        }
        let fileURL = LocalStore.cacheDirectory.appendingPathComponent(name)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    static func getCacheImage(fileName name: String) -> UIImage? {
        let fileURL = LocalStore.cacheDirectory.appendingPathComponent(name)
        return  UIImage(contentsOfFile: fileURL.path)
    }
    
}

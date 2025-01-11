//
//  CacheManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 08/01/25.
//


import Foundation
import SwiftUI


class CacheManager {
    static let instance = CacheManager()
    private init() {
        
    }
    
    var photoCache: NSCache<NSString, UIImage> = {
        var cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 1024 * 1024 * 200 //200mb
        return cache
    }()
    
    func addPhoto(key: String, image: UIImage) {
        photoCache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(key: String) -> UIImage?  {
        return photoCache.object(forKey: key as NSString)
    }
    
}

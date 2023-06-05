//
//  UIImageView+LoadImage.swift
//  WeatherApp
//
//  Created by Karun Kumaron 03/06/23.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage? = UIImage(named: "placeholder")) {
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
                    DispatchQueue.main.async { [weak self] in
                        self?.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            self?.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}

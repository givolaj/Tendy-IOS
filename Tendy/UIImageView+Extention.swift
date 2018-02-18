//
//  UIImageView+Extention.swift
//  Tendy
//
//  Created by Erez on 18/02/2018.
//  Copyright © 2018 ATN. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                var image = UIImage(data: data)
                
                else { return }
            DispatchQueue.main.async() {
            
                image = image.squared!
                self.image = image.imageResize(sizeChange: self.frame.size)

                
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

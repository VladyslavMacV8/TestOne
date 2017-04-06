//
//  Extensions.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/19/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

let imageChache = NSCache<AnyObject, AnyObject>()

func delay(_ seconds: Double, completion: @escaping ()->Void) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime, execute: completion)
}

extension UIImageView {
    func retrieveImageFrom(url: String) {
        self.image = nil
        guard let url = URL(string: url) else { return }
        
        if let chachedImage = imageChache.object(forKey: url as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.image = chachedImage
                return
            }
        } else {
            let urlRequest = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                DispatchQueue.main.async {
                    guard let imageData = data else { return }
                    if let downloadedImage = UIImage(data: imageData) {
                        imageChache.setObject(downloadedImage, forKey: url as AnyObject)
                        self.image = downloadedImage
                    }
                }
            }.resume()
            
        }
    }
    
    func retrieveImageFrom(data: Data) {
        self.image = nil
        guard let dataImage = UIImage(data: data) else { return }
        DispatchQueue.main.async {
            self.image = dataImage
        }
    }
}

extension UIViewController {
    func alertControllerWith(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension UITableViewController {
    func reloadDataWithAnimation() {
        UIView.transition(with: self.tableView, duration: 0.7, options: .transitionCrossDissolve, animations: {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, completion: nil)
    }
}

extension UICollectionViewController {
    func reloadDataWithAnimation() {
        UIView.transition(with: self.collectionView!, duration: 0.7, options: .transitionCrossDissolve, animations: {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }, completion: nil)
    }
}

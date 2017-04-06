//
//  LoadNewsDBTableViewCell.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/22/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import RealmSwift

class LoadNewsDBTableViewCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    var newsId: String?
    
    func updateNews(_ checked: Bool) {
        if let realm = try? Realm(),
            let id = self.newsId,
            let news = realm.object(ofType: News.self, forPrimaryKey: id as AnyObject) {
            
            let newsRef = ThreadSafeReference(to: news)
            
            DispatchQueue(label: "background").async {
                let realmBackground = try! Realm()
                
                guard let news = realmBackground.resolve(newsRef) else { return }
                
                try! realmBackground.write {
                    news.done = checked
                }
            }

            checkButton.isSelected = news.done
        } 
    }
    
    func configNews(_ news: News) {
        newsId = news.newsId
        checkButton.isSelected = news.done
        photoImageView.retrieveImageFrom(data: news.imageData! as Data)
        titleLabel.text = news.name
        sourceLabel.text = news.source
    }
    
    @IBAction func readImageChecked(_ sender: UIButton) {
        updateNews(!checkButton.isSelected)
    }
}

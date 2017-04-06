//
//  DetailNewsViewController.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/19/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import RealmSwift

class DetailNewsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var author: String!
    var about: String!
    var name: String!
    var urlToImage: String!
    var imageData: Data!
    var date: String!
    var source: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail News"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = name
        urlToImage != nil ? photoImageView.retrieveImageFrom(url: urlToImage) : photoImageView.retrieveImageFrom(data: imageData)
        aboutLabel.text = about
        authorLabel.text = author
        dateLabel.text = date
    }
    
    @IBAction func saveDataToRealmAction(_ sender: UIButton) {
        do {
            let imageData = NSData(contentsOf: URL(string: urlToImage)!)
            let news = News(author: author, about: about, name: name, imageData: imageData!, date: date, source: source)
            
            let realm = try Realm()
            try realm.write {
                
                realm.add(news)
                
                sender.setTitle("Saved", for: .normal)
                delay(0.7, completion: {
                    sender.setTitle("Save", for: .normal)
                })
            }
        } catch {
            alertControllerWith("Error saved data")
        }
    }
}

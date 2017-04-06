//
//  RealmModel.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/22/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation
import RealmSwift

class News: Object {
    dynamic var author: String = ""
    dynamic var about: String = ""
    dynamic var name: String = ""
    dynamic var imageData: NSData? = nil
    dynamic var date: String = ""
    dynamic var source: String = ""
    
    dynamic var done = false
    dynamic var newsId = UUID().uuidString
    
    convenience init(author: String, about: String, name: String, imageData: NSData, date: String, source: String) {
        self.init()
        self.author = author
        self.about = about
        self.name = name
        self.imageData = imageData
        self.date = date
        self.source = source
    }
    
    override class func primaryKey() -> String? {
        return "newsId"
    }
    
    override class func indexedProperties() -> [String] {
        return ["done"]
    }
}

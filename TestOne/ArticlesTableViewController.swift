//
//  ArticlesTableViewController.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/17/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

class ArticlesTableViewController: UITableViewController {
    
    fileprivate static let apiKey = "b34bdeb945f14d12a883b0e38ff5f874"
    var array: [Article] = []
    var newId: String!
    var sorted: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "News"
        
        retrieveData()
    }
    
    func retrieveData() {
        provider.request(.aricles(newId, sorted, ArticlesTableViewController.apiKey)) { (result) in
            do {
                let response = try result.dematerialize()
                let value = try response.mapDictionary()
                
                if let articles = value["articles"] as? [[String : AnyObject]] {
                    
                    for article in articles {
                        let newArticle = Article()
                        
                        if let title = article["title"] as? String {
                            newArticle.title = title
                        } else {
                            newArticle.title = "Not Title"
                        }
                        
                        if let author = article["author"] as? String {
                            newArticle.author = author
                        } else {
                            newArticle.author = "Unknown author"
                        }
                        
                        if let about = article["description"] as? String {
                            if about == "" {
                                newArticle.about = "Not description"
                            } else {
                                newArticle.about = about
                            }
                        } else {
                            newArticle.about = "Not description"
                        }
                        
                        if let date = article["publishedAt"] as? String {
                            newArticle.date = date
                        } else {
                            newArticle.date = "Not date"
                        }
                        
                        if var urlToImage = article["urlToImage"] as? String {
                            
                            if urlToImage == "" {
                                newArticle.urlToImage = "http://www.terapiaparkinson.it/wp-content/uploads/2016/05/news.jpg"
                            } else {
                                
                                if urlToImage.range(of: "https:") != nil {
                                    
                                    let loBound = urlToImage.index(urlToImage.startIndex, offsetBy: 4)
                                    let hiBound = urlToImage.index(urlToImage.startIndex, offsetBy: 5)
                                    let miBound = loBound ..< hiBound
                                    urlToImage.removeSubrange(miBound)
                                    
                                    newArticle.urlToImage = urlToImage
                                } else if urlToImage.range(of: "http:") != nil {
                                    newArticle.urlToImage = urlToImage
                                } else {
                                    newArticle.urlToImage = "http:" + urlToImage
                                }
                                
                            }

                        } else {
                            newArticle.urlToImage = "http://www.terapiaparkinson.it/wp-content/uploads/2016/05/news.jpg"
                        }
                    
                        self.array.append(newArticle)
                    }
                }
                self.reloadDataWithAnimation()
            } catch {
                let printableError = error as? CustomStringConvertible
                let errorMessage = printableError?.description ?? "unable to fetch from news."
                self.alertControllerWith("Error retrieve data, " + errorMessage)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.width / 3
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let newCell = cell as! ArticlesTableViewCell
        
        newCell.titleLabel.text = self.array[indexPath.row].title
        newCell.dateLabel.text = self.array[indexPath.row].date
        newCell.photoImageView.retrieveImageFrom(url: self.array[indexPath.row].urlToImage)
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let detailNewsVC = segue.destination as! DetailNewsViewController
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            let article = self.array[(indexPath?.row)!] as Article
            
            detailNewsVC.author = article.author
            detailNewsVC.urlToImage = article.urlToImage
            detailNewsVC.about = article.about
            detailNewsVC.date = article.date
            detailNewsVC.name = article.title
            detailNewsVC.source = newId
        }
    }
}

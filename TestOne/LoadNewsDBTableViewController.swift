//
//  LoadNewsDBTableViewController.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/22/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import RealmSwift

class LoadNewsDBTableViewController: UITableViewController {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortingSCOutlet: UISegmentedControl!

    var newsResult: Results<News>!
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Realm"

        newsResult = getNews(false).sorted(byKeyPath: "source")
        token = notificationToken(newsResult)
    }
    
    @IBAction func sortingRealmDataAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            newsResult = newsResult.sorted(byKeyPath: "source")
        case 1:
            newsResult = newsResult.sorted(byKeyPath: "name")
        default:
            break
        }
        token = notificationToken(newsResult)
    }
    
    @IBAction func readingFilter(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        newsResult = getNews(sender.isSelected).sorted(byKeyPath: "source")
        sortingSCOutlet.selectedSegmentIndex = 0
        token = notificationToken(newsResult)
    }
    
    func getNews(_ done: Bool) -> Results<News> {
        do {
            let realm = try Realm()
            newsResult = realm.objects(News.self)
            
            if done {
                newsResult = newsResult.filter("done = true")
            } else {
                newsResult = newsResult.filter("done = false")
            }
        } catch let error as NSError {
            alertControllerWith("Error get news, " + error.localizedDescription)
        }
 
        return newsResult
    }
    
    func notificationToken(_ news: Results<News>) -> NotificationToken {
        return news.addNotificationBlock({ [weak self] (changes: RealmCollectionChange<Results<News>>) in
            self?.updateUI(changes)
        })
    }
    
    func updateUI(_ changes: RealmCollectionChange<Results<News>>) {
        switch changes {
        case .initial(_):
            reloadDataWithAnimation()
        case .update(_, deletions: let deletions, insertions: let insertions, modifications: _):
            tableView.beginUpdates()
            tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .left)
            tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .right)
            tableView.endUpdates()
            break
        case .error(let error): 
            alertControllerWith("Not update UI, " + error.localizedDescription)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.width / 3
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let newCell = cell as! LoadNewsDBTableViewCell
        
        let news = self.newsResult[indexPath.row]
        newCell.configNews(news)
        
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try newsResult.realm?.write {
                    let news = self.newsResult[indexPath.row]
                    self.newsResult.realm?.delete(news)
                }
            } catch {
                alertControllerWith("Error deleted")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailFromDB" {
            let detailNewsVC = segue.destination as! DetailNewsViewController
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            let article = self.newsResult[(indexPath?.row)!] as News
            
            detailNewsVC.saveButton.isHidden = true
            
            detailNewsVC.author = article.author
            detailNewsVC.imageData = article.imageData as Data!
            detailNewsVC.about = article.about
            detailNewsVC.date = article.date
            detailNewsVC.name = article.name
        }
    }
}

//
//  SourcesCollectionViewController.swift
//  TestOne
//
//  Created by Vladyslav Kudelia on 3/20/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "collectionCell"

class SourcesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var array: [Source] = []
    var sorted: String = "top"
    var value: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.delegate = self
        
        retrieveData()
    }
    
    func retrieveData() {
        provider.request(.source) { (result) in
            do {
                let response = try result.dematerialize()
                let value = try response.mapDictionary()
                
                if let sources = value["sources"] as? [[String: AnyObject]] {
                    for source in sources {
                        let newSource = Source()
                        if let id = source["id"] as? String,
                            let name = source["name"] as? String,
                            let urlToImage = source["urlsToLogos"] as? [String: AnyObject],
                            let urlToLogo = urlToImage["small"] as? String {
                            
                            newSource.id = id
                            newSource.name = name
                            newSource.image = urlToLogo
                        }
                        self.array.append(newSource)
                    }
                }
                self.reloadDataWithAnimation()
            } catch {
                let printableError = error as? CustomStringConvertible
                let errorMessage = printableError?.description ?? "unable to fetch from sources."
                self.alertControllerWith("Error retrieve data, " + errorMessage)
            }
        }
    }
    
    @IBAction func sortedSigmentedControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            return sorted = "top"
        case 1:
            return sorted = "latest"
        case 2:
            return sorted = "popular"
        default:
            break
        }
    }
    
    @IBAction func oneByOneAction(_ sender: UIBarButtonItem) {
        value = false
        reloadDataWithAnimation()
    }
    
    @IBAction func twoByTwoAction(_ sender: UIBarButtonItem) {
        value = true
        reloadDataWithAnimation()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let newCell = cell as! SourcesCollectionViewCell
        
        newCell.titleLabel.text = self.array[indexPath.item].name
        newCell.photoImageView.retrieveImageFrom(url: self.array[indexPath.item].image)
    
        return newCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let number: CGFloat = (self.collectionView?.bounds.width)! / 2
        return value ? CGSize(width: number * 0.95, height: number) : CGSize(width: number, height: number / 2)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNews" {
            let articleVC = segue.destination as! ArticlesTableViewController
            let indexPath = self.collectionView?.indexPath(for: sender as! UICollectionViewCell)
            let articles = self.array[(indexPath?.item)!] as Source
            
            articleVC.newId = articles.id
            articleVC.sorted = sorted
        }
    }
}

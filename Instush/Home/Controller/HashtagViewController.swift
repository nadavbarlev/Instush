//
//  HashtagViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 02/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HashtagViewController: UIViewController {

    // MARK: Properties
    var hashtagText: String?
    var hashtagPosts = [Post]()
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HashtagToPostDetailsSegue" {
            let postDetailVC = segue.destination as! PostDetailsViewController
            guard let post = sender as? Post else { return }
            postDetailVC.post = post
        }
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let hashtagText = hashtagText?.dropFirst() else { return }
        HashTagService.shared.search(for: hashtagText.lowercased()) { (post: Post) in
            self.hashtagPosts.append(post)
            self.collectionView.reloadData()
        }
    }
}


// MARK: Extension - Collection Data Source and Delegate
extension HashtagViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /* Collection Data Source */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hashtagPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.updateUI(imagePath: hashtagPosts[indexPath.row].photoURL)
        return cell
    }
    
    /* Collection Flow Layout Delegate */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let edgeCell = collectionView.frame.width / 3 - 1
        return CGSize(width: edgeCell, height: edgeCell)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    /* Collection Delegate */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "HashtagToPostDetailsSegue", sender: hashtagPosts[indexPath.row])
    }
}


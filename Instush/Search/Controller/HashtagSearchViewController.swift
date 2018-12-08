//
//  HashtagSearchViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 26/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HashtagSearchViewController: UIViewController {
    
    // MARK: Properties
    var hashtagPosts = [Post]()
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.keyboardDismissMode = .interactive
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hashtagPosts.removeAll()
        collectionView.reloadData()
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToPostDetailsSegue" {
            let postDetailVC = segue.destination as! PostDetailsViewController
            guard let post = sender as? Post else { return }
            postDetailVC.post = post
        }
    }
}

// MARK: Extension - Search Bar Events
extension HashtagSearchViewController: SearchBarLinstener {
    func onTextChanged(searchText: String) {
        self.hashtagPosts.removeAll()
        self.collectionView.reloadData()
        HashTagService.shared.search(for: searchText.lowercased()) { (post: Post) in
            self.hashtagPosts.append(post)
            self.collectionView.reloadData()
        }
    }
    func onSearchClicked() {
        view.endEditing(true) // TODONADAV
    }
}

// MARK: Extension - Collection Data Source and Delegate
extension HashtagSearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        performSegue(withIdentifier: "SearchToPostDetailsSegue", sender: hashtagPosts[indexPath.row])
    }
}

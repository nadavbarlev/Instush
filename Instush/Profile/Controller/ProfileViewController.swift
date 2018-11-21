//
//  ProfileViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: Properties
    var user: User?
    var userPosts = [Post]()
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userID = UserService.shared.getCurrentUserID() else { return }
        
        UserService.shared.getUser(by: userID) { [weak self] in
            self?.user = $0
            self?.collectionView.reloadData()
        }
        
        PostService.shared.getPosts(ofUser: userID) { [weak self] in
            self?.userPosts.append($0)
            self?.collectionView.reloadData()
        }
    }
}

// MARK: Extension - Collection Data Source and Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /* Collection Data Source */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.updateUI(imagePath: userPosts[indexPath.row].photoURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                             withReuseIdentifier: "HeaderProfileCollection",
                                                                             for: indexPath) as! HeaderProfileCollectionReusableView
        guard let user = user else { return headerViewCell }
        headerViewCell.updateUI(user: user)
        return headerViewCell
    }
    
    /* Collection Flow Layout Delegate */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                                            sizeForItemAt indexPath: IndexPath) -> CGSize {
        let edgeCell = collectionView.frame.width / 3 - 1
        return CGSize(width: edgeCell, height: edgeCell)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
}

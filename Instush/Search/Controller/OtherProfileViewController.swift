//
//  OtherProfileViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 27/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class OtherProfileViewController: UIViewController {
    
    // MARK: Properties
    var user: User? {
        didSet { self.navigationItem.title = user?.username }
    }
    var userPosts = [Post]()
    var delegate: OtherProfileViewControllerDelegate?
    
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
        
        guard let userID = user?.userID else { return }
        
        UserService.shared.getUser(by: userID) { [weak self] in
            self?.user = $0
            self?.collectionView.reloadData()
        }
        
        PostService.shared.getPosts(ofUser: userID) { [weak self] in
            self?.userPosts.append($0)
            self?.collectionView.reloadData()
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OtherProfileToFollowerSegue" {
            let followVC = segue.destination as! FollowViewController
            followVC.isFollowers = true
            followVC.userToCheck = user?.userID
        } else if segue.identifier == "OtherProfileToFollowingSegue" {
            let followVC = segue.destination as! FollowViewController
            followVC.isFollowers = false
            followVC.userToCheck = user?.userID
        } else if segue.identifier == "OtherProfileToPostDetailsSegue" {
            let postDetailsVC = segue.destination as! PostDetailsViewController
            postDetailsVC.post = sender as? Post
        }
    }
}

// MARK: Extension - Collection Data Source and Flow Layout Delegate
extension OtherProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
                                                                             withReuseIdentifier: "HeaderOtherProfileCollection",
                                                                             for: indexPath) as! HeaderOtherProfileCollectionReusableView
        guard let user = user else { return headerViewCell }
        headerViewCell.delegateMove = self
        headerViewCell.delegateFollow = self
        headerViewCell.user = user
        return headerViewCell
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
        performSegue(withIdentifier: "OtherProfileToPostDetailsSegue", sender: userPosts[indexPath.row])
    }
}

// MARK: Events from Other Header Profile
extension OtherProfileViewController: ProfileToFollowDelegate, OtherProfileViewControllerDelegate {

    func moveToFollowers() {
        self.performSegue(withIdentifier: "OtherProfileToFollowerSegue", sender: self)
    }
    
    func moveToFollowing() {
        self.performSegue(withIdentifier: "OtherProfileToFollowingSegue", sender: self)
    }
    
    func onFollowStateChanged(to isFollowing: Bool, of userID: String) {
        delegate?.onFollowStateChanged(to: isFollowing, of: userID)
    }
}

// MARK: Protocol
protocol OtherProfileViewControllerDelegate {
    func onFollowStateChanged(to isFollowing: Bool, of userID: String)
}

protocol ProfileToFollowDelegate {
     func moveToFollowers()
     func moveToFollowing()
}

//
//  HomeViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, PostTableViewCellDelegate {
   
    // MARK: Properties
    var user: User?
    var posts = Array<Post>()
    var users = Array<User>()
    
    // MARK: Outlets
    @IBOutlet weak var labelNoFeed: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableViewPosts: UITableView! {
        didSet {
            tableViewPosts.estimatedRowHeight = 500
            tableViewPosts.rowHeight = UITableView.automaticDimension
            tableViewPosts.dataSource = self
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userID = UserService.shared.getCurrentUserID() else { return }
        UserService.shared.getUser(by: userID) { self.user = $0 }
        
        /* Start indicator (appears just on animation) */
        labelNoFeed.isHidden = true
        indicatorView.startAnimating()

        /* Listen for add and remove FEED posts */
        PostService.shared.getFeedPosts(ofUser: userID, onAddPost: { [weak self] (newPost: Post?) in
            guard let feedPost = newPost else {
                self?.indicatorView.stopAnimating()
                self?.labelNoFeed.isHidden = false
                return
            }
            UserService.shared.getUser(by: feedPost.userID) { [weak self] (user: User) in
                self?.users.append(user)
                self?.posts.append(feedPost)
                self?.indicatorView.stopAnimating()
                self?.labelNoFeed.isHidden = true
                self?.tableViewPosts.reloadData()
            }
        }, onRemovePost: { (postID: String) in
            if let indexToRemove = self.posts.firstIndex(where: { $0.postID == postID }) {
                self.posts.remove(at: indexToRemove)
                self.users.remove(at: indexToRemove)
                self.tableViewPosts.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToCommentsSegue" {
            guard let postID = sender as? String else { return }
            guard let commentsVC = segue.destination as? CommentsViewController else { return }
            commentsVC.currentPostID = postID
        }
        else if segue.identifier == "HomeToProfileSegue" {
            guard let user = sender as? User else { return }
            guard let profileVC = segue.destination as? ProfileViewController else { return }
            profileVC.user = user
        } else if segue.identifier == "HomeToOtherProfileSegue" {
            guard let user = sender as? User else { return }
            guard let otherProfileVC = segue.destination as? OtherProfileViewController else { return }
            otherProfileVC.user = user
        }
    }
    
    // PostTableViewCellDelegate - Implementation
    func onUpdate(post: Post) {
        let updatedPost = posts.first { $0.postID == post.postID }
        updatedPost?.likesCount = post.likesCount
        updatedPost?.usersLike = post.usersLike
    }
    
    func onCommentPostClicked(postID: String) {
        self.performSegue(withIdentifier: "HomeToCommentsSegue", sender: postID)
    }
    
    func onUsernameClicked(userID: String) {
        if userID == UserService.shared.getCurrentUserID() {
            let user = users.first { $0.userID == userID }
            self.performSegue(withIdentifier: "HomeToProfileSegue", sender: user)
            return
        }
        else  {
            let user = users.first { $0.userID == userID }
            self.performSegue(withIdentifier: "HomeToOtherProfileSegue", sender: user)
        }
    }
}

// MARK: Extension - TableView Events
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        cell.user = users[indexPath.row]
        cell.post = posts[indexPath.row]
        cell.updateUI()
        cell.delegate = self
        return cell
    }
}

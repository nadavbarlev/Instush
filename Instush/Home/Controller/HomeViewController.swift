//
//  HomeViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
   
    // MARK: Contants
    let CHUNK_OF_POSTS_TO_LOAD = 3
    
    // MARK: Properties
    var appUserID: String?
    var posts = Array<Post>()
    var users = Array<User>()
    var isFeedLoading = false
    let refreshControl = UIRefreshControl()
    
    // MARK: Outlets
    @IBOutlet weak var labelNoFeed: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableViewPosts: UITableView! {
        didSet {
            tableViewPosts.estimatedRowHeight = 500
            tableViewPosts.rowHeight = UITableView.automaticDimension
            tableViewPosts.dataSource = self
            tableViewPosts.delegate = self
            tableViewPosts.addSubview(refreshControl)
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get current user app */
        appUserID = UserService.shared.getCurrentUserID()
        guard let userID = appUserID else { return }
        
        /* Add Target when refresh table posts */
        refreshControl.addTarget(self, action: #selector(refreshFeedPosts(userID:)), for: .valueChanged)
        
        /* Start indicator (appears just on animation) */
        labelNoFeed.isHidden = true
        indicatorView.startAnimating()

        /* Get chunck of feed posts */
        loadFeedPosts(of: userID)
        
        /* Listen for removing feed post */
        PostService.shared.onPostFeedRemove(userID: userID) { (postID: String) in
            if let indexToRemove = self.posts.firstIndex(where: { $0.postID == postID }) {
                self.posts.remove(at: indexToRemove)
                self.users.remove(at: indexToRemove)
                self.tableViewPosts.reloadData()
            }
        }
    }
    
    // MARK: Action and Events
    @objc func refreshFeedPosts(userID: String) {
        self.users.removeAll()
        self.posts.removeAll()
        loadFeedPosts(of: userID)
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
        } else if segue.identifier == "HomeToHashtagSegue" {
            guard let text = sender as? String else { return }
            guard let hashtagVC = segue.destination as? HashtagViewController else { return }
            hashtagVC.hashtagText = text
        }
    }
    
    // MARK: Private Methods
    private func loadFeedPosts(of UserID: String) {
        isFeedLoading = true
        PostService.shared.getFeedPosts(of: UserID, recent: CHUNK_OF_POSTS_TO_LOAD, end: nil) { (feedData: [(Post, User)]?) in
            self.indicatorView.stopAnimating()
            guard let feedData = feedData else {
                self.labelNoFeed.isHidden = false
                return
            }
    
            self.labelNoFeed.isHidden = true
            for (post, user) in feedData {
                self.users.append(user)
                self.posts.append(post)
            }
            
            self.isFeedLoading = false
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.tableViewPosts.reloadData()
        }
    }
    
    private func loadMoreFeedPosts(of userID: String) {
        guard !isFeedLoading else { return }
        guard let latestPostTimestamp = self.posts.last?.timestamp else { return }
        
        isFeedLoading = true
        PostService.shared.getFeedPosts(of: userID, recent: CHUNK_OF_POSTS_TO_LOAD, end: -latestPostTimestamp+1) { (feedData: [(Post, User)]?) in
            guard let feedData = feedData else { return }
            for (post, user) in feedData {
                self.users.append(user)
                self.posts.append(post)
            }
            self.isFeedLoading = false
            self.tableViewPosts.reloadData()
        }
    }
}

// MARK: Extension - TableView Events
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        if !users.isEmpty && !posts.isEmpty {
            cell.post = posts[indexPath.row]
            cell.user = users[indexPath.row]
            cell.updateUI()
            cell.delegate = self
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.height >= scrollView.contentSize.height {
            loadMoreFeedPosts(of: appUserID!)
        }
    }
}

// MARK: Extension - Post Cell Delegate
extension HomeViewController: PostTableViewCellDelegate {
 
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
        let user = users.first { $0.userID == userID }
        self.performSegue(withIdentifier: "HomeToOtherProfileSegue", sender: user)
    }
    
    func onHashtagClicked(text: String) {
        self.performSegue(withIdentifier: "HomeToHashtagSegue", sender: text)
    }
    
    func onMentionClicked(text: String) {
        let username = text.dropFirst().lowercased()
        UserService.shared.getUser(byUsername: username) { (user: User) in
            if user.userID == UserService.shared.getCurrentUserID() {
                self.performSegue(withIdentifier: "HomeToProfileSegue", sender: user)
                return
            }
            self.performSegue(withIdentifier: "HomeToOtherProfileSegue", sender: user)
        }
    }
}

//
//  HomeViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
   
    // MARK: Properties
    var user: User?
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
        
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        guard let userID = UserService.shared.getCurrentUserID() else { return }
        UserService.shared.getUser(by: userID) { self.user = $0 }
        
        /* Start indicator (appears just on animation) */
        labelNoFeed.isHidden = true
        indicatorView.startAnimating()

        /* Listen for add and remove FEED posts
        PostService.shared.getFeedPosts(ofUser: userID, recent: 2, from:0, onAddPost: { [weak self] (newPost: Post?) in
            guard let feedPost = newPost else {
                self?.indicatorView.stopAnimating()
                self?.labelNoFeed.isHidden = false
                return
            }
            UserService.shared.getUser(by: feedPost.userID) { [weak self] (user: User) in
            
               // self?.users.insert(user, at: 0)
                // self?.posts.insert(feedPost, at: 0)
 
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
        }) */
        
        isFeedLoading = true
        PostService.shared.getFeedPosts(ofUser: userID, recent: 2, from: nil) { [weak self] (feedData: [(Post, User)]?) in
            self?.indicatorView.stopAnimating()
            guard let feedData = feedData else {
                self?.labelNoFeed.isHidden = false
                return
            }
            
            self?.labelNoFeed.isHidden = true
            for (post, user) in feedData {
                self?.users.append(user)
                self?.posts.append(post)
            }
            
            self?.isFeedLoading = false
            self?.tableViewPosts.reloadData()
        }
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
        } else if segue.identifier == "HomeToHashtagSegue" {
            guard let text = sender as? String else { return }
            guard let hashtagVC = segue.destination as? HashtagViewController else { return }
            hashtagVC.hashtagText = text
        }
    }
    
    // MARK: Private Methods
    private func loadPosts() {
        isFeedLoading = true
        guard let userID = user?.userID else { return }
        PostService.shared.getFeedPosts(ofUser: userID, recent: 2, from: nil) { [weak self] (feedData: [(Post, User)]?) in
            self?.indicatorView.stopAnimating()
            guard let feedData = feedData else {
                self?.labelNoFeed.isHidden = false
                return
            }
            
            self?.labelNoFeed.isHidden = true
            for (post, user) in feedData {
                self?.users.append(user)
                self?.posts.append(post)
            }
            
            self?.isFeedLoading = false
            if self!.refreshControl.isRefreshing {
                self?.refreshControl.endRefreshing()
            }
            self?.tableViewPosts.reloadData()
        }
    }
    
    private func loadMorePosts() {
        guard !isFeedLoading else { return }
        isFeedLoading = true
        guard let latestPostTimestamp = self.posts.last?.timestamp else {
            isFeedLoading = false
            return
        }
        guard let userID = user?.userID else { return }
        PostService.shared.getFeedPosts(ofUser: userID, recent: 2, end: -latestPostTimestamp+1) { [weak self] (feedData: [(Post, User)]?) in
            guard let feedData = feedData else { return }
            for (post, user) in feedData {
                self?.users.append(user)
                self?.posts.append(post)
            }
            self?.isFeedLoading = false
            self?.tableViewPosts.reloadData()
        }
    }
    
    @objc func refreshPosts() {
        self.users.removeAll()
        self.posts.removeAll()
        loadPosts()
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
           loadMorePosts()
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

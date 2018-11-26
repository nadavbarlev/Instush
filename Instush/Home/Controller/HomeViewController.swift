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
    var userID = UserService.shared.getCurrentUserID()
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
   
    // MARK: Actions
    @IBAction func logout(_ sender: UIBarButtonItem) {
        UserService.shared.signOut(onSuccess: {
            let storyboardStart = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboardStart.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }, onError: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Start indicator (appears just on animation) */
        labelNoFeed.isHidden = true
        indicatorView.startAnimating()

        /* Listen for add and remove FEED posts */
        guard let userID = userID else { return }
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
    }
    
    // PostTableViewCellDelegate - Implementation
    func onUpdate(post: Post) {
        let updatedPost = posts.first { $0.postID == post.postID }
        updatedPost?.likesCount = post.likesCount
        updatedPost?.usersLike = post.usersLike
    }
}

// MARK: Extension - TableView Events
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        guard let currUserID = userID else { return cell }
        let postViewModel = PostViewModel(post: posts[indexPath.row], user: users[indexPath.row], userID: currUserID)
        cell.updateUI(with: postViewModel)
        cell.postID = posts[indexPath.row].postID
        cell.delegate = self
        cell.homeVC = self
        return cell
    }
}

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
    var posts = Array<Post>()
    var users = Array<User>()
    
    // MARK: Outlets
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
        /*
        ServiceManager.auth.signOut(onSuccess: {
            let storyboardStart = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboardStart.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }, onError: { (error: Error) in
            print(error.localizedDescription)
        })
 */
        // self.performSegue(withIdentifier: "HomeToCommentsSegue", sender: nil)
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Start indicator (appears just on animation) */
        indicatorView.startAnimating()

        /* Gets all Posts and corresponding Users */
        PostService.shared.listener { [weak self] (newPost: Post) in
            UserService.shared.getUser(by: newPost.userID) { [weak self] (user: User) in
                self?.users.append(user)
                self?.posts.append(newPost)
                self?.indicatorView.stopAnimating()
                self?.tableViewPosts.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToCommentsSegue" {
            guard let postID = sender as? String else { return }
            guard let commentsVC = segue.destination as? CommentsViewController else { return }
            commentsVC.currentPostID = postID
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
        let postViewModel = PostViewModel(post: posts[indexPath.row], user: users[indexPath.row])
        cell.updateUI(with: postViewModel)
        cell.postID = posts[indexPath.row].postID
        cell.homeVC = self
        return cell
    }
}

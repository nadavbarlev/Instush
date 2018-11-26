//
//  FollowViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 21/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class FollowViewController: UIViewController {

    // MARK: Properties
    var isFollowers: Bool?      /* Following or Followers Controller */
    var usersFollow = [User]()
    let appUserID = UserService.shared.getCurrentUserID()
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelNoContent: UILabel!
    @IBOutlet weak var tableViewFollow: UITableView! {
        didSet {
            tableViewFollow.dataSource = self
            tableViewFollow.keyboardDismissMode = .onDrag
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let isFollowers = isFollowers else { return }
        isFollowers ? configureFollowers() : configureFollowing()
    }
    
    // MARK: Methods
    private func configureFollowers() {
        self.title = "Followers"
        guard let userID = appUserID else { return }
        activityIndicator.startAnimating()
        FollowService.shared.getFollowers(after: userID) { (followingUser) in
            self.activityIndicator.stopAnimating()
            guard let followingUser = followingUser else {
                self.labelNoContent.isHidden = false
                self.labelNoContent.text = "No Followers"
                return
            }
            self.labelNoContent.isHidden = true
            self.usersFollow.append(followingUser)
            self.tableViewFollow.reloadData()
        }
    }
    
    private func configureFollowing() {
        self.title = "Following"
        guard let userID = appUserID else { return }
        activityIndicator.startAnimating()
        FollowService.shared.getFollowing(of: userID) { (followedUser) in
            self.activityIndicator.stopAnimating()
            guard let followedUser = followedUser else {
                self.labelNoContent.isHidden = false
                self.labelNoContent.text = "No Following"
                return
            }
            self.labelNoContent.isHidden = true
            self.usersFollow.append(followedUser)
            self.tableViewFollow.reloadData()
        }
    }
}

// MARK: Extension - Table View Data Source
extension FollowViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersFollow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
        cell.user = usersFollow[indexPath.row]
        return cell
    }
}

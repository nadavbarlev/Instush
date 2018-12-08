//
//  PeopleUIViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 25/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class SearchPeopleViewController: UIViewController {

    // MARK: Properties
    var users = [User]()
    var currentSearchText = ""
   
    // MARK: Outlets
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.keyboardDismissMode = .onDrag
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.startAnimating()
        UserService.shared.searchUsers(withText: "") { (user: User) in
            if (user.userID != UserService.shared.getCurrentUserID()) {
                self.indicatorView.stopAnimating()
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.users.removeAll()
        self.tableView.reloadData()
    }
}

// MARK: Extension - TableView Data Source
extension SearchPeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
        cell.selectionStyle = .none
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let otherProfileVC = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController")
            as! OtherProfileViewController
        otherProfileVC.user = users[indexPath.row]
        otherProfileVC.delegate = self
        self.navigationController?.pushViewController(otherProfileVC, animated: true)
    }
}

// MARK: Extension - Search Bar Events
extension SearchPeopleViewController: SearchBarLinstener {
    func onTextChanged(searchText: String) {
        currentSearchText = searchText
        self.users.removeAll()
        self.tableView.reloadData()
        UserService.shared.searchUsers(withText: searchText.lowercased()) { (user: User) in
            if (user.userID != UserService.shared.getCurrentUserID() &&
                searchText == self.currentSearchText ) {
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }
    func onSearchClicked() {
        view.endEditing(true)
    }
}

extension SearchPeopleViewController: OtherProfileViewControllerDelegate {
    func onFollowStateChanged(to isFollowing: Bool, of userID: String) {
        users.first { $0.userID == userID }?.isAppUserFollowAfterMe = isFollowing
        tableView.reloadData()
    }
}

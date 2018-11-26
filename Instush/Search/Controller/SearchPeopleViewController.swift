//
//  PeopleUIViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 25/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class SearchPeopleViewController: UIViewController, SearchBarLinstener {

    // MARK: Properties
    var users = [User]()
   
    // MARK: Outlets
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.keyboardDismissMode = .onDrag
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.startAnimating()
        UserService.shared.searchUsers(withText: "") { (user: User) in
            self.indicatorView.stopAnimating()
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    // MARK: Search Bar Events
    func onTextChanged(searchText: String) {
        self.users.removeAll()
        self.tableView.reloadData()
        UserService.shared.searchUsers(withText: searchText.lowercased()) { (user: User) in
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
}

// MARK: Extension - TableView Data Source
extension SearchPeopleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
}

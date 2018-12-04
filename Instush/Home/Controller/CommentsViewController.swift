//
//  CommentsViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 15/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {

    // MARK: Properties
    var currentPostID: String?
    var comments = Array<Comment>()
    var users    = Array<User>()
    
    // MARK: Outlets
    @IBOutlet weak var tableViewComments: UITableView! {
        didSet {
            tableViewComments.rowHeight = 70
            tableViewComments.estimatedRowHeight = UITableView.automaticDimension
            tableViewComments.dataSource = self
            tableViewComments.keyboardDismissMode = .onDrag
        }
    }
    @IBOutlet weak var textFieldComment: UITextField!
    @IBOutlet weak var buttonPost: UIButton!
    @IBOutlet weak var consBottomTextFieldComment: NSLayoutConstraint!
    
    // MARK: Actions and Events
    @IBAction func postComment(_ sender: UIButton) {

        guard let postID = currentPostID else { return }
        guard let comment = textFieldComment.text, !comment.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Comment is empty")
            return
        }
        
        CommentService.shared.postComment(on: postID, comment: comment, onSuccess: {
            self.showTopToast(onView: self.view, withMessage: "Post")
            self.textFieldComment.text = ""
            self.view.endEditing(true)
        }, onError: {(error: Error) in
           self.showTopToast(onView: self.view, withMessage: error.localizedDescription)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentToHashtagSegue" {
            guard let hashtagVC = segue.destination as? HashtagViewController else { return }
            guard let text = sender as? String else { return }
            hashtagVC.hashtagText = text
        } else if segue.identifier == "CommentToProfileSegue" {
            guard let profileVC = segue.destination as? ProfileViewController else { return }
            guard let user = sender as? User else { return }
            profileVC.user = user
        } else if segue.identifier == "CommentToOtherProfileSegue" {
            guard let otherProfileVC = segue.destination as? OtherProfileViewController else { return }
            guard let user = sender as? User else { return }
            otherProfileVC.user = user
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let postID = currentPostID else { return }
        CommentService.shared.listener(to: postID) { [weak self] (comment: Comment) in
            UserService.shared.getUser(by: comment.userID) { [weak self] (user: User) in
                self?.users.append(user)
                self?.comments.append(comment)
                self?.tableViewComments.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.registerKeyboardNotifications(willShowSelector: #selector(keyboardWillShow),
                                           willHideSelector: #selector(keyboardWillHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.unregisterKeyboardNotifications()
    }
}

// MARK: Extension - TableView Events
extension CommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let commentVM = CommentViewModel(comment: comments[indexPath.row], user: users[indexPath.row])
        cell.updateUI(commentViewModel: commentVM)
        cell.delegate = self
        return cell
    }
}

// MARK: Extension - Protocol CommentTableViewCellDelegate
extension CommentsViewController: CommentTableViewCellDelegate {
    func onHashtagClicked(text: String) {
        let hasgtag = text.dropFirst().lowercased()
        self.performSegue(withIdentifier: "CommentToHashtagSegue", sender: hasgtag)
    }
    
    func onMentionClicked(text: String) {
        let username = text.dropFirst().lowercased()
        UserService.shared.getUser(byUsername: username) { (user: User) in
            if user.userID == UserService.shared.getCurrentUserID() {
                self.performSegue(withIdentifier: "CommentToProfileSegue", sender: user)
                return
            }
            self.performSegue(withIdentifier: "CommentToOtherProfileSegue", sender: user)
        }
    }
}


// MARK: Extension - Keyboard Events
extension CommentsViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardHeight = keyboardFrame?.cgRectValue.height else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.consBottomTextFieldComment.constant = keyboardHeight
            self.view.layoutIfNeeded()
            let scrollPoint = CGPoint(x: 0, y: self.tableViewComments.contentSize.height - self.tableViewComments.frame.size.height)
            self.tableViewComments.setContentOffset(scrollPoint, animated: true)
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.consBottomTextFieldComment.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}

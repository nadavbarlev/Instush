//
//  PostDetailsViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 29/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class PostDetailsViewController: UIViewController {

    // MARK: Properties
    var post: Post?
    var user: User?
    
    // MARK: Outlets
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var labelLikes: UILabel!
    @IBOutlet weak var labelUsername: UILabel! {
        didSet {
            labelUsername.onClick(target: self, action: #selector(onUsernameClicked))
        }
    }
    @IBOutlet weak var imageViewPost: UIImageView! {
        didSet {
            imageViewPost.onDoubleClick(target: self, action: #selector(onLikeClicked))
        }
    }
    @IBOutlet weak var imageViewComment: UIImageView! {
        didSet {
            imageViewComment.onClick(target: self, action: #selector(onCommmentClicked))
        }
    }
    @IBOutlet weak var imageViewLike: UIImageView!{
        didSet {
            imageViewLike.onClick(target: self, action: #selector(onLikeClicked))
        }
    }
    @IBOutlet weak var imageViewProfile: UIImageView! {
        didSet {
            imageViewProfile.layer.masksToBounds = false
            imageViewProfile.layer.cornerRadius = imageViewProfile.frame.height/2
            imageViewProfile.clipsToBounds = true
        }
    }
    
    // MARK: Actions and Events
    @objc func onCommmentClicked() {
        guard let post = post else { return }
        let storyboardHome = UIStoryboard(name: "Home", bundle: nil)
        let commentsVC = storyboardHome.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsVC.currentPostID = post.postID
        self.show(commentsVC, sender: self)
    }
    
    @objc func onUsernameClicked() {
        guard let post = post else { return }
        if post.userID == ServiceManager.auth.getUserID() {
            let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.show(profileVC, sender: self)
        } else {
            let storyboardSearch = UIStoryboard(name: "Search", bundle: nil)
            let otherProfileVC = storyboardSearch.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
            self.show(otherProfileVC, sender: self)
        }
    }
    
    @objc func onLikeClicked() {
        guard let post = post else { return}
        PostService.shared.Like(postID: post.postID) { (post: Post) in
            guard let id = ServiceManager.auth.getUserID() else { return }
            let isLikedByUser = post.usersLike[id] != nil
            self.updateLikeUI(count: String(post.likesCount), isUserLiked: isLikedByUser)
        }
    }
    
    // MARK: LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        guard let post = post else { return }
        self.navigationItem.title = "photo"
        UserService.shared.getUser(by: post.userID) { [weak self] in
            self?.user = $0
            self?.updateUI()
        }
        PostService.shared.listener(to: post.postID) { [weak self] (changedPost: Post) in
            self?.post = changedPost
            self?.updateUI()
        }
    }
    
    // MARK: Private methods
    func updateUI() {
        guard let post = post else { return }
        guard let user = user else { return }
        DispatchQueue.main.async {
            self.labelUsername.text = user.username
            self.labelCaption.text  = post.caption
            self.imageViewPost.sd_setImage(with: URL(string: post.photoURL))
            self.imageViewProfile.sd_setImage(with: URL(string: user.profileImgURL),
                                              placeholderImage: UIImage(named: "Placeholder-ProfileImg"))
            let isUserLiked = post.usersLike[user.userID] != nil
            self.updateLikeUI(count: String(post.likesCount), isUserLiked: isUserLiked)
        }
    }
    
    func updateLikeUI(count: String, isUserLiked: Bool) {
        let imageText: String
        let imageName = isUserLiked ? "like_Selected" : "like"
        if count == "0" {
            imageText = "Be the first to like this photo"
        } else if count == "1" {
            imageText = count + " like"
        } else {
            imageText = count + " likes"
        }
        DispatchQueue.main.async {
            self.labelLikes.text = imageText
            self.imageViewLike.image = UIImage(named: imageName)
        }
    }

}

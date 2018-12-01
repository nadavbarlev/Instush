//
//  PostTableViewCell.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit
import SDWebImage

protocol PostTableViewCellDelegate {
    func onUpdate(post: Post) -> ()
    func onCommentPostClicked(postID: String)
    func onUsernameClicked(userID: String)
}

class PostTableViewCell: UITableViewCell {

    // MARK: Properties
    var post: Post?
    var user: User?
    var delegate: PostTableViewCellDelegate?
    
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
        delegate?.onCommentPostClicked(postID: post.postID)
    }
    
    @objc func onUsernameClicked() {
        guard let post = post else { return }
        delegate?.onUsernameClicked(userID: post.userID)
    }
    
    @objc func onLikeClicked() {
        guard let post = post else { return}
        PostService.shared.Like(postID: post.postID) { (post: Post) in
            guard let id = self.user?.userID else { return }
            let isLikedByUser = post.usersLike[id] != nil
            self.updateLikeUI(count: String(post.likesCount), isUserLiked: isLikedByUser)
            self.delegate?.onUpdate(post: post)
        }
    }
    
    // MARK: LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let postID = post?.postID else { return }
        PostService.shared.listener(to: postID) { [weak self] (changedPost: Post) in
            self?.post = changedPost
            self?.updateUI()
        }
    }
    
    // MARK: Methods
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

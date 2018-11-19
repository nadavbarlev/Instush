//
//  PostTableViewCell.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {

    // MARK: Properties
    var userID = UserService.shared.getCurrentUserID()
    var homeVC: HomeViewController?
    var postID: String?
    var delegate: PostTableViewCellDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var labelLikes: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView! {
        didSet {
            imageViewProfile.layer.masksToBounds = false
            imageViewProfile.layer.cornerRadius = imageViewProfile.frame.height/2
            imageViewProfile.clipsToBounds = true
        }
    }
    @IBOutlet weak var imageViewPost: UIImageView! {
        didSet {
            imageViewPost.onDoubleClick(target: self,
                                        action: #selector(onLikeClicked))
        }
    }
    @IBOutlet weak var imageViewComment: UIImageView! {
        didSet {
            imageViewComment.onClick(target: self,
                                     action: #selector(onCommmentClicked))
        }
    }
    @IBOutlet weak var imageViewLike: UIImageView!{
        didSet {
            imageViewLike.onClick(target: self,
                                  action: #selector(onLikeClicked))
        }
    }
    
    // MARK: Actions and Events
    @objc func onCommmentClicked() {
        homeVC?.performSegue(withIdentifier: "HomeToCommentsSegue", sender: postID)
    }
    
    @objc func onLikeClicked() {
        guard let postID = postID else { return}
        PostService.shared.Like(postID: postID) { (post: Post) in
            guard let id = self.userID else { return }
            let isLikedByUser = post.usersLike[id] != nil
            self.updateLikeUI(count: String(post.likesCount), isUserLiked: isLikedByUser)
            self.delegate?.onUpdate(post: post)
        }
    }
    
    // MARK: LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        labelUsername.text = ""
        labelCaption.text  = ""
    }
    
    // MARK: Methods
    func updateUI(with viewModelPost: PostViewModel) {
        DispatchQueue.main.async {
            self.labelUsername.text = viewModelPost.username
            self.labelCaption.text  = viewModelPost.caption
            self.imageViewPost.sd_setImage(with: URL(string: viewModelPost.postImgURL))
            self.imageViewProfile.sd_setImage(with: URL(string: viewModelPost.profileImgURL),
                                         placeholderImage: UIImage(named: "Placeholder-ProfileImg"))
            self.updateLikeUI(count: viewModelPost.likeCount, isUserLiked: viewModelPost.isUserLiked)
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

// MARK: Protocol
protocol PostTableViewCellDelegate {
    func onUpdate(post: Post) -> ()
}

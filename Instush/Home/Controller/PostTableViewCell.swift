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

    // MARK: Outlets
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var imageViewComment: UIImageView!
    @IBOutlet weak var labelLikes: UILabel!
    @IBOutlet weak var labelCaption: UILabel!
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
                                        action: #selector(onPhotoDoubleClicked))
        }
    }
    @IBOutlet weak var imageViewLike: UIImageView!{
        didSet {
            imageViewLike.onClick(target: self,
                                  action: #selector(onLikeClicked))
        }
    }
    
    // MARK: Actions and Events
    @objc func onLikeClicked() {
        print("Click")
    }
    
    @objc func onPhotoDoubleClicked() {
        print("Double")
    }
    
    // MARK: LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        labelUsername.text = ""
        labelCaption.text  = ""
    }
    
    // MARK: Methods
    func updateUI(with viewModelPost: PostViewModel) {
        labelUsername.text = viewModelPost.username
        labelCaption.text  = viewModelPost.caption
        imageViewPost.sd_setImage(with: URL(string: viewModelPost.postImgURL))
        imageViewProfile.sd_setImage(with: URL(string: viewModelPost.profileImgURL),
                                     placeholderImage: UIImage(named: "Placeholder-ProfileImg"))
    }
}

//
//  CommentTableViewCell.swift
//  Instush
//
//  Created by Nadav Bar Lev on 15/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit
import KILabel

protocol CommentTableViewCellDelegate {
    func onHashtagClicked(text: String)
    func onMentionClicked(text: String)
}

class CommentTableViewCell: UITableViewCell {

    // MARK: Properties
    var delegate: CommentTableViewCellDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView! {
        didSet {
            imageViewProfile.layer.masksToBounds = false
            imageViewProfile.layer.cornerRadius = imageViewProfile.frame.height/2
            imageViewProfile.clipsToBounds = true
        }
    }
    @IBOutlet weak var labelComment: KILabel! {
        didSet {
            labelComment.hashtagLinkTapHandler = { (label, string, range) in
                self.delegate?.onHashtagClicked(text: string)
            }
            labelComment.userHandleLinkTapHandler = { (label, string, range) in
                self.delegate?.onMentionClicked(text: string)
            }
        }
    }
    
    // MARK: Methods
    func updateUI(commentViewModel: CommentViewModel) {
        labelComment.text = commentViewModel.comment
        labelUsername.text = commentViewModel.username
        imageViewProfile.sd_setImage(with: URL(string: commentViewModel.profileImgPath))
    }
    
    // MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        labelUsername.text = ""
        labelComment.text = ""
        imageViewProfile.image = nil
    }
}

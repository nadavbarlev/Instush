//
//  HeaderProfileCollectionReusableView.swift
//  Instush
//
//  Created by Nadav Bar Lev on 20/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    // MARK: Outlets
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelProfileCaption: UILabel!
    @IBOutlet weak var labelPostCount: UILabel!
    @IBOutlet weak var labelFollowersCount: UILabel!
    @IBOutlet weak var labelFollowingCount: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView! {
        didSet {
            imageViewProfile.layer.cornerRadius = imageViewProfile.frame.height/2
            imageViewProfile.clipsToBounds = true
        }
    }
    @IBOutlet weak var buttonEditProfile: UIButton! {
        didSet {
            buttonEditProfile.layer.cornerRadius = 4.0
            buttonEditProfile.layer.borderWidth = 1.0
            buttonEditProfile.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    // MARK: Actions
    @IBAction func editProfile(_ sender: UIButton) {
    }
    
    // MARK: Methods
    func updateUI(user: User) {
        labelUsername.text = user.username
        imageViewProfile.sd_setImage(with: URL(string: user.profileImgURL))
    }
}

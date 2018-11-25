//
//  HeaderProfileCollectionReusableView.swift
//  Instush
//
//  Created by Nadav Bar Lev on 20/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    // MARK: Properties
    var profileVC: ProfileViewController?
    var userID = UserService.shared.getCurrentUserID()
    
    // MARK: Outlets
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelProfileCaption: UILabel!
    @IBOutlet weak var labelPostCount: UILabel!
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
    @IBOutlet weak var labelFollowersCount: UILabel! {
        didSet {
           
            labelFollowersCount.onClick(target: self, action: #selector(showFollowers))
        }
    }
    @IBOutlet weak var labelFollowingCount: UILabel! {
        didSet {
            labelFollowingCount.onClick(target: self, action: #selector(showFollowing))
        }
    }
    
    override func awakeFromNib() {
        /*
 
         guard let appUserID = userID else { return }
         FollowService.shared.getFollowingCount(of: appUserID) { [weak self] (followingCount) in
         self?.labelFollowingCount.text = String(followingCount)
         }
         
         */
        print("dsasdasd")
    }
    
    // MARK: Actions and Events
    @IBAction func editProfile(_ sender: UIButton) {
    }
    
    @objc func showFollowers() {
        profileVC?.performSegue(withIdentifier: "ProfileToFollowersSegue", sender: self)
    }
    
    @objc func showFollowing() {
        profileVC?.performSegue(withIdentifier: "ProfileToFollowingSegue", sender: self)
    }
    
    // MARK: Methods
    func updateUI(user: User) {
        labelUsername.text = user.username
        imageViewProfile.sd_setImage(with: URL(string: user.profileImgURL))
    }
}

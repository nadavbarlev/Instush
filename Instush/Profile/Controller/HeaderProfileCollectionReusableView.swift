//
//  HeaderProfileCollectionReusableView.swift
//  Instush
//
//  Created by Nadav Bar Lev on 20/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit


protocol HeaderProfileCollectionReusableViewDelegate {
    func moveToFollowers()
    func moveToFollowing()
    func moveToEditProfile()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    // MARK: Properties
    var delegate: HeaderProfileCollectionReusableViewDelegate?
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
        guard let userID = userID else { return }
        PostService.shared.getPostCount(for: userID) { (postCount: Int) in
            self.labelPostCount.text = String(postCount)
        }
        FollowService.shared.getFollowersCount(for: userID) { (followersCount: Int) in
              self.labelFollowersCount.text = String(followersCount)            
        }
        FollowService.shared.getFollowingCount(for: userID)  { (followingCount: Int) in
            self.labelFollowingCount.text = String(followingCount)
        }
    }
    
    // MARK: Actions and Events
    @IBAction func editProfile(_ sender: UIButton) {
      // delegate?.moveToEditProfile()
        UserService.shared.signOut(onSuccess: {
         
        }, onError: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    @objc func showFollowers() {
        delegate?.moveToFollowers()
    }
    
    @objc func showFollowing() {
        delegate?.moveToFollowing()
    }
    
    // MARK: Methods
    func updateUI(user: User) {
         guard let userID = userID else { return }
        labelUsername.text = user.username
        imageViewProfile.sd_setImage(with: URL(string: user.profileImgURL))
    }
}

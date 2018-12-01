//
//  HeaderOtherProfileCollectionReusableView.swift
//  Instush
//
//  Created by Nadav Bar Lev on 27/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HeaderOtherProfileCollectionReusableView: UICollectionReusableView {
    
    // MARK: Properties
    var delegateMove: ProfileToFollowDelegate?
    var delegateFollow: OtherProfileViewControllerDelegate?
    var user: User? { didSet { updateUI() } }
    
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
    @IBOutlet weak var buttonFollow: UIButton! {
        didSet {
            buttonFollow.layer.cornerRadius = 4.0
            buttonFollow.layer.borderWidth = 1.0
            buttonFollow.layer.borderColor = UIColor.lightGray.cgColor
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
    
    // MARK: LifeCycle
    override func awakeFromNib() {
    }
    
    // MARK: Private Methods
    private func updateUI() {
        guard let user = user else { return }
        labelUsername.text = user.username
        imageViewProfile.sd_setImage(with: URL(string: user.profileImgURL))
        user.isAppUserFollowAfterMe ? setUnfollowButton() : setFollowButton()
        PostService.shared.getPostCount(for: user.userID) { (postCount: Int) in
            self.labelPostCount.text = String(postCount)
        }
        FollowService.shared.getFollowersCount(for: user.userID) { (followersCount: Int) in
            self.labelFollowersCount.text = String(followersCount)
        }
        FollowService.shared.getFollowingCount(for: user.userID)  { (followingCount: Int) in
            self.labelFollowingCount.text = String(followingCount)
        }
    }
    
    func setUnfollowButton() {
        DispatchQueue.main.async {
            self.buttonFollow.removeTarget(self, action: nil, for: .touchUpInside)
            self.buttonFollow.addTarget(self, action: #selector(self.unfollow), for: .touchUpInside)
            self.buttonFollow.layer.borderWidth = 1
            self.buttonFollow.layer.borderColor = UIColor.lightGray.cgColor
            self.buttonFollow.backgroundColor = UIColor.white
            self.buttonFollow.setTitle("Following", for: .normal)
            self.buttonFollow.setTitleColor(UIColor.darkText, for: .normal)
            self.user?.isAppUserFollowAfterMe = true
        }
    }
    
    func setFollowButton() {
        DispatchQueue.main.async {
            self.buttonFollow.removeTarget(self, action: nil, for: .touchUpInside)
            self.buttonFollow.addTarget(self, action: #selector(self.follow), for: .touchUpInside)
            self.buttonFollow.layer.borderWidth = 0
            self.buttonFollow.layer.borderColor = UIColor.clear.cgColor
            self.buttonFollow.backgroundColor = UIColor.purple
            self.buttonFollow.setTitle("Follow", for: .normal)
            self.buttonFollow.setTitleColor(UIColor.white, for: .normal)
            self.user?.isAppUserFollowAfterMe = false
        }
    }

    
    // MARK: Actions and Events
    @objc func follow() {
        guard let cellUserID = self.user?.userID else { return }
        guard let appUserID = UserService.shared.getCurrentUserID() else { return }
        FollowService.shared.follow(after: cellUserID, by: appUserID, onSuccess: { [weak self] in
            self?.setUnfollowButton()
            self?.delegateFollow?.onFollowStateChanged(to: true, of: cellUserID)
            }, onError: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    @objc func unfollow() {
        guard let cellUserID = self.user?.userID else { return }
        guard let appUserID = UserService.shared.getCurrentUserID() else { return }
        FollowService.shared.unfollow(from: cellUserID, by: appUserID, onSuccess: { [weak self] in
            self?.setFollowButton()
            self?.delegateFollow?.onFollowStateChanged(to: false, of: cellUserID)
            }, onError: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    @objc func showFollowers() {
        delegateMove?.moveToFollowers()
    }
    
    @objc func showFollowing() {
        delegateMove?.moveToFollowing()
    }
}

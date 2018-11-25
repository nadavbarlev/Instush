//
//  FollowTableViewCell.swift
//  Instush
//
//  Created by Nadav Bar Lev on 21/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {

    // MARK: Properties
    var user: User? {
        didSet { updateUI() }
    }
    
    // MARK: Outlets
    @IBOutlet weak var imageViewProfile: UIImageView! {
        didSet {
            imageViewProfile.layer.cornerRadius = imageViewProfile.frame.height/2
            imageViewProfile.clipsToBounds = true
        }
    }
    @IBOutlet weak var buttonFollow: UIButton! {
        didSet {
            buttonFollow.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelMail: UILabel!
    
    // MARK: Actions and Events
    @objc func follow() {
        guard let cellUserID = self.user?.userID else { return }
        guard let appUserID = UserService.shared.getCurrentUserID() else { return }
        FollowService.shared.follow(after: cellUserID, by: appUserID, onSuccess: { [weak self] in
            self?.setUnfollowButton()
        }, onError: { (error: Error) in 
            print(error.localizedDescription)
        })
    }
    
    @objc func unfollow() {
        guard let cellUserID = self.user?.userID else { return }
        guard let appUserID = UserService.shared.getCurrentUserID() else { return }
        FollowService.shared.unfollow(from: cellUserID, by: appUserID, onSuccess: { [weak self] in
            self?.setFollowButton()
        }, onError: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    // MARK: Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: Methods
    private func updateUI() {
        guard let cellUser = self.user else { return }
        labelUsername.text = cellUser.username
        labelMail.text = cellUser.email
        imageViewProfile.sd_setImage(with: URL(string: cellUser.profileImgURL))
        cellUser.isAppUserFollowAfterMe ? setUnfollowButton() : setFollowButton()
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
}

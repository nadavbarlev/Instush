//
//  EditProfileTableViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 29/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: Properties
    var user: User?
    var isClickOnChangeProfile = false
    
    // MARK: Outlets
    @IBOutlet weak var imageViewProfile: UIImageView! {
        didSet {
            imageViewProfile.layer.cornerRadius = imageViewProfile.frame.height/2
            imageViewProfile.clipsToBounds = true
        }
    }
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldBio: UITextField!
    
    // MARK: Actions and Events
    @IBAction func chooseProfileImg(_ sender: UIButton) {
        isClickOnChangeProfile = true
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard let userID = user?.userID else { return }
        guard let username = textFieldUsername.text, !username.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Please enter valid username")
            textFieldUsername.text = user?.username
            return
        }
        guard let email = textFieldEmail.text, !email.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Please enter valid email address")
            textFieldEmail.text = user?.email
            return
        }
        guard let profileImgData = imageViewProfile.image?.jpegData(compressionQuality: 0.2) else {
            self.showTopToast(onView: view, withMessage: "Please choose valid profile image")
            return
        }
        if username == user?.username && email == user?.email && !isClickOnChangeProfile {
            return
        }
        
        let spinnerView = self.spinnerOn(self.view, withText: "")
        UserService.shared.updateInfo(of: userID, username: username, email: email, imageData: profileImgData, onSuccess: {
            self.spinnerOff(spinnerView)
            self.showCenterToast(onView: self.view, withMessage: "Success")
        }, onError: { (error: Error) in
            self.spinnerOff(spinnerView)
            self.showCenterToast(onView: self.view, withMessage: error.localizedDescription)
        })
    }
    
    @IBAction func logout(_ sender: UIButton) {
        UserService.shared.signOut(onSuccess: {
            let storyboardStart = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboardStart.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }, onError: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        textFieldUsername.text = user?.username
        textFieldEmail.text    = user?.email
        guard let strProfileImg = user?.profileImgURL else { return }
        imageViewProfile.sd_setImage(with: URL(string: strProfileImg))
    }

    // MARK: Table View Methods
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0.1 }
        if section == 1 { return 10 }
        return 50
    }
    
    // MARK: Text Field Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Extension - Image Picker Events
extension EditProfileTableViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imgProfileSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageViewProfile.image = imgProfileSelected
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

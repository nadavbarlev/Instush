//
//  SignUpViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 04/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var textFieldUsername: UITextField! {
        didSet {
            textFieldUsername.delegate = self
            textFieldUsername.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldUsername.placeholder else { return }
            textFieldUsername.attributedPlaceholder =
                        NSAttributedString(string: textPlaceHolder,
                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBOutlet weak var textFieldEmail: UITextField! {
        didSet {
            textFieldEmail.delegate = self
            textFieldEmail.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldEmail.placeholder else { return }
            textFieldEmail.attributedPlaceholder =
                        NSAttributedString(string: textPlaceHolder,
                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBOutlet weak var textFieldPassword: UITextField! {
        didSet {
            textFieldPassword.delegate = self
            textFieldPassword.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldPassword.placeholder else { return }
            textFieldPassword.attributedPlaceholder =
                    NSAttributedString(string: textPlaceHolder,
                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBOutlet weak var buttonSignUp: UIButton! {
        didSet {
            buttonSignUp.backgroundColor = .clear 
            buttonSignUp.layer.cornerRadius = 5
            buttonSignUp.layer.borderWidth = 0.5
            buttonSignUp.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet weak var imgProfile: UIImageView! {
        didSet{
            imgProfile.layer.borderWidth = 1.5
            imgProfile.layer.masksToBounds = false
            imgProfile.layer.borderColor = UIColor.lightGray.cgColor
            imgProfile.layer.cornerRadius = imgProfile.frame.height/2
            imgProfile.clipsToBounds = true
 
            // Enable onClick on imageView
            imgProfile.onClick(target: self,
                               action: #selector(SignUpViewController.onProfileImageClicked))
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonHaveAccount: UIButton!
    @IBOutlet weak var consScrollViewBottom: NSLayoutConstraint!
    
    // MARK: Actions
    @IBAction func haveAccount(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        guard let username = textFieldUsername.text, !username.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Please enter your username")
            return
        }
        guard let email = textFieldEmail.text, !email.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Please enter your email address")
            return
        }
        guard let password = textFieldPassword.text, !password.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Please enter your password")
            return
        }
        guard let profileImgData = imgProfile.image?.jpegData(compressionQuality: 0.2) else {
            self.showTopToast(onView: view, withMessage: "Please choose profile image")
            return
        }
       
        let spinnerView = self.spinnerOn(self.view, withText: "Sign Up...")
        ServiceManager.auth.signUp(withEmail: email, password: password, username: username, imageData: profileImgData, onSuccess: {
            self.performSegue(withIdentifier: "signUpToMainSegue", sender: nil)
            self.spinnerOff(spinnerView)
        }, onError: { (error: Error) in
            self.spinnerOff(spinnerView)
            self.showTopToast(onView: self.view, withMessage: error.localizedDescription)
            print(error)
        })
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboardOnTapAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications(willShowSelector: #selector(keyboardWillShow),
                                           willHideSelector: #selector(keyboardWillHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.unregisterKeyboardNotifications()
    }
    
    // MARK: TextField Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldUsername:
           textFieldEmail.becomeFirstResponder()
        case textFieldEmail:
            textFieldPassword.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}

// MARK: Extension - Image Picker Events
extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func onProfileImageClicked() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imgProfileSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgProfile.image = imgProfileSelected
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: Extension - Keyboard Events
extension SignUpViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardHeight = keyboardFrame?.cgRectValue.height else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.consScrollViewBottom.constant = keyboardHeight - 30
            self.view.layoutIfNeeded()
        })
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.consScrollViewBottom.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}

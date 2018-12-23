//
//  SignInViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 04/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var consScrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var textFieldEmail: UITextField! {
        didSet {
            textFieldEmail.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldEmail.placeholder else { return }
            textFieldEmail.attributedPlaceholder = NSAttributedString(string: textPlaceHolder,
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            textFieldEmail.delegate = self
        }
    }
    @IBOutlet weak var textFieldPassword: UITextField! {
        didSet {
            textFieldPassword.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldPassword.placeholder else { return }
            textFieldPassword.attributedPlaceholder = NSAttributedString(string: textPlaceHolder,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            textFieldPassword.delegate = self
        }
    }
    @IBOutlet weak var buttonSignIn: UIButton! {
        didSet {
            buttonSignIn.backgroundColor = .clear
            buttonSignIn.layer.cornerRadius = 5
            buttonSignIn.layer.borderWidth = 0.5
            buttonSignIn.layer.borderColor = UIColor.white.cgColor
        }
    }
   
    // MARK: Actions
    @IBAction func signIn(_ sender: UIButton) {
        guard let email = textFieldEmail.text, !email.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Please enter your email address")
            return
        }
        guard let password = textFieldPassword.text, !password.isEmpty else {
            self.showTopToast(onView: view, withMessage: "Please enter your password")
            return
        }
        
        let spinnerView = self.spinnerOn(self.view, withText:"Sign In...")
        UserService.shared.signIn(withEmail: email, password: password, onSuccess: {
            self.performSegue(withIdentifier: "signInToMainSegue", sender: nil)
            self.spinnerOff(spinnerView)
        }, onError: { (error: Error) in
            self.spinnerOff(spinnerView)
            self.showTopToast(onView: self.view, withMessage: error.localizedDescription)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserService.shared.isUserSignedIn() {
            self.performSegue(withIdentifier: "signInToMainSegue", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.unregisterKeyboardNotifications()
    }
    
    // MARK: TextField Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
            return false
        }
        textField.resignFirstResponder()
        return false
    }
}

// MARK: Extension - Keyboard Events
extension SignInViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardHeight = keyboardFrame?.cgRectValue.height else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.consScrollViewBottom.constant = keyboardHeight - 60
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

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
        guard let email = textFieldEmail.text, !email.isEmpty else { return }
        guard let password = textFieldPassword.text, !password.isEmpty else { return }
        ServiceManager.auth.signIn(withEmail: email, password: password, onSuccess: {
            self.performSegue(withIdentifier: "signInToMainSegue", sender: nil)
        }, onError: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboardOnTapAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ServiceManager.auth.isUserSignedIn() {
            self.performSegue(withIdentifier: "signInToMainSegue", sender: nil)
        }
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

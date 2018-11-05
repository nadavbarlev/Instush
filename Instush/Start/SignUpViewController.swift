//
//  SignUpViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 04/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var textFieldUsername: UITextField! {
        didSet {
            textFieldUsername.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldUsername.placeholder else { return }
            textFieldUsername.attributedPlaceholder =
                NSAttributedString(string: textPlaceHolder,
                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    @IBOutlet weak var textFieldEmail: UITextField! {
        didSet {
            textFieldEmail.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldEmail.placeholder else { return }
            textFieldEmail.attributedPlaceholder =
                NSAttributedString(string: textPlaceHolder,
                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    @IBOutlet weak var textFieldPassword: UITextField! {
        didSet {
            textFieldPassword.backgroundColor = UIColor(white: 1, alpha: 0.2)
            guard let textPlaceHolder = textFieldPassword.placeholder else { return }
            textFieldPassword.attributedPlaceholder =
                NSAttributedString(string: textPlaceHolder,
                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
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
            /*
            imgProfile.layer.borderWidth = 1.5
            imgProfile.layer.masksToBounds = false
            imgProfile.layer.borderColor = UIColor.black.cgColor
            imgProfile.layer.cornerRadius = imgProfile.frame.height/2
            imgProfile.clipsToBounds = true
            */
        }
    }
    
    // MARK: Actions
    @IBAction func haveAccount(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: UIButton) {
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

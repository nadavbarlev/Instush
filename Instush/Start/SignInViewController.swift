//
//  SignInViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 04/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    // MARK: Outlets
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
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

//
//  HomeViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: Actions
    @IBAction func logout(_ sender: UIBarButtonItem) {
        ServiceManager.auth.signOut(onSuccess: {
            let storyboardStart = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboardStart.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }, onError: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

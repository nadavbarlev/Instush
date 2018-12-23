//
//  WalkthroughContentViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 03/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    // MARK: Properties
    var index: Int = 0
    var content: String?
    
    // MARK: Outlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var buttonStart: UIButton! {
        didSet {
            buttonStart.backgroundColor = .clear
            buttonStart.layer.cornerRadius = 5
            buttonStart.layer.borderWidth = 0.5
            buttonStart.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    // MARK: Actions
    @IBAction func start(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "isWalkthroughDisplayed")
        guard let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController")
                as? SignInViewController else { return }
        self.present(signInVC, animated: true, completion: nil)
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        labelContent.text = content
        pageControl.currentPage = index
        labelTitle.isHidden = (index != 0)
        buttonStart.isHidden = (index != 2)
    }
}

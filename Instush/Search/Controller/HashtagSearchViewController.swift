//
//  HashtagSearchViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 26/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class HashtagSearchViewController: UIViewController, SearchBarLinstener {
    
    
    func onTextChanged(searchText: String) {
        print("HashtagSearchViewController")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  UIImageViewExtenstions.swift
//  Instush
//
//  Created by Nadav Bar Lev on 12/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func onClick(target: Any?, action: Selector?) {
        let tapGestureImg = UITapGestureRecognizer(target: target, action: action)
        tapGestureImg.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureImg)
        self.isUserInteractionEnabled = true
    }
    
    func onDoubleClick(target: Any?, action: Selector?) {
        let tapGestureImg = UITapGestureRecognizer(target: target, action: action)
        tapGestureImg.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGestureImg)
        self.isUserInteractionEnabled = true
    }
}

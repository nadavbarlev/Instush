//
//  PhotoCollectionViewCell.swift
//  Instush
//
//  Created by Nadav Bar Lev on 20/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Methods
    func updateUI(imagePath: String) {
        imageView.sd_setImage(with: URL(string: imagePath))
    }
}

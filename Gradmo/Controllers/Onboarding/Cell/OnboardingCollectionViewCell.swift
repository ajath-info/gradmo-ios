//
//  OnboardingCollectionViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 14/03/26.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var slideImageView: UIImageView!

       func setup(_ slide: OnboardingSlide) {
           slideImageView.image = slide.image
       }
   }


struct OnboardingSlide {
    let image: UIImage
}

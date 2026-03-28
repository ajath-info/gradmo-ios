//
//  BannerCollectionViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 21/03/26.
//

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bannerImageView: UIImageView!
    
    // MARK: - Life Cycle
     override func awakeFromNib() {
         super.awakeFromNib()
         setupUI()
     }

     override func prepareForReuse() {
         super.prepareForReuse()
         bannerImageView.image = nil
     }

     // MARK: - Setup
     private func setupUI() {
         bannerImageView.clipsToBounds = true
         bannerImageView.layer.cornerRadius = 12
         bannerImageView.contentMode = .scaleAspectFill

         contentView.layer.cornerRadius = 12
         contentView.layer.masksToBounds = true

         // Optional shadow (applied on cell layer, not contentView)
         layer.shadowColor = UIColor.black.cgColor
         layer.shadowOpacity = 0.08
         layer.shadowOffset = CGSize(width: 0, height: 3)
         layer.shadowRadius = 6
         layer.masksToBounds = false
     }

     // MARK: - Configuration
     func configure(image: UIImage?) {
         bannerImageView.image = image
     }
 }

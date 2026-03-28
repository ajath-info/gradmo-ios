//
//  InstituteDetailCollectionViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 22/03/26.
//

import UIKit

class InstituteDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var instituteImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStar1ImageView: UIImageView!
    @IBOutlet weak var ratingStar2ImageView: UIImageView!
    @IBOutlet weak var ratingStar3ImageView: UIImageView!
    @IBOutlet weak var ratingStar4ImageView: UIImageView!
    @IBOutlet weak var ratingStar5ImageView: UIImageView!
    @IBOutlet weak var instituteNameLabel: UILabel!
    @IBOutlet weak var instituteAddressLabel: UILabel!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var hybridImageView: UIImageView!
    @IBOutlet weak var offlineImageView: UIImageView!
    
    // MARK: - Properties
        private var starImageViews: [UIImageView] {
            return [
                ratingStar1ImageView,
                ratingStar2ImageView,
                ratingStar3ImageView,
                ratingStar4ImageView,
                ratingStar5ImageView
            ]
        }

        // MARK: - Life Cycle
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            resetUI()
        }

        // MARK: - Setup
        private func setupUI() {
            instituteImageView.clipsToBounds = true
            instituteImageView.layer.cornerRadius = 10
            
            contentView.layer.cornerRadius = 12
            contentView.layer.masksToBounds = true
            
            // Optional shadow (if needed, apply on cell not contentView)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.05
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 6
            layer.masksToBounds = false
        }

        private func resetUI() {
            instituteImageView.image = nil
            instituteNameLabel.text = nil
            instituteAddressLabel.text = nil
            ratingLabel.text = nil
            
            updateRating(0)
            
            onlineImageView.isHidden = true
            hybridImageView.isHidden = true
            offlineImageView.isHidden = true
        }

        // MARK: - Configuration
        func configure(
            name: String,
            address: String,
            rating: Double,
            image: UIImage?,
            modes: [InstituteMode]
        ) {
            instituteNameLabel.text = name
            instituteAddressLabel.text = address
            ratingLabel.text = String(format: "%.1f", rating)
            instituteImageView.image = image
            
            updateRating(rating)
            updateModes(modes)
        }

        // MARK: - Rating Logic
        private func updateRating(_ rating: Double) {
            for (index, imageView) in starImageViews.enumerated() {
                if Double(index) < rating {
                    imageView.image = UIImage(systemName: "star.fill")
                    imageView.tintColor = .systemYellow
                } else {
                    imageView.image = UIImage(systemName: "star")
                    imageView.tintColor = .lightGray
                }
            }
        }

        // MARK: - Mode Handling
        private func updateModes(_ modes: [InstituteMode]) {
            onlineImageView.isHidden = !modes.contains(.online)
            hybridImageView.isHidden = !modes.contains(.hybrid)
            offlineImageView.isHidden = !modes.contains(.offline)
        }
    }

    // MARK: - Enum
    enum InstituteMode {
        case online
        case hybrid
        case offline
    }

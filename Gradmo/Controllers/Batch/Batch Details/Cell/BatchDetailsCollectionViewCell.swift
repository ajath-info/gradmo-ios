//
//  BatchDetailsCollectionViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 05/04/26.
//

import UIKit
import SDWebImage

class BatchDetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var instituteImageView: UIImageView!
    @IBOutlet weak var instituteNameLabel: UILabel!
    @IBOutlet weak var batchNameLabel: UILabel!
    @IBOutlet weak var teacherNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadow()
    }
    
}

extension BatchDetailsCollectionViewCell{
    func setupUI(){
        contentView.clipsToBounds = false
        clipsToBounds = false

        mainView.layer.cornerRadius = 12
        mainView.layer.masksToBounds = true
        
        instituteImageView.layer.cornerRadius = 12
        instituteNameLabel.font = UIFont.GilroyBold(ofSize: 14)
        batchNameLabel.font = UIFont.GilroySemiBold(ofSize: 12)
        teacherNameLabel.font = UIFont.GilroyRegular(ofSize: 12)
        timeLabel.font = UIFont.GilroyRegular(ofSize: 12)
        subjectLabel.font = UIFont.GilroyRegular(ofSize: 10)
        gradeLabel.font = UIFont.GilroyRegular(ofSize: 10)
        ratingLabel.font = UIFont.GilroyRegular(ofSize: 10)
        
        subjectLabel.layer.borderWidth = 1
        subjectLabel.layer.borderColor = UIColor.theme.cgColor
        subjectLabel.layer.cornerRadius = self.subjectLabel.frame.height / 2
        
        gradeLabel.layer.borderWidth = 1
        gradeLabel.layer.borderColor = UIColor(hex: "#FF7300").cgColor
        gradeLabel.layer.cornerRadius = self.gradeLabel.frame.height / 2
    }

    func configure(instituteName: String,
                   batchName: String,
                   teacherName: String,
                   time: String,
                   rating: String,
                   subject: String,
                   grade: String,
                   image: UIImage?,
                   imageURL: String?) {
        instituteNameLabel.text = instituteName
        batchNameLabel.text = batchName
        teacherNameLabel.text = teacherName
        timeLabel.text = time
        ratingLabel.text = rating
        subjectLabel.text = subject
        gradeLabel.text = grade
        let placeholderImage = image ?? UIImage(named: "institutePlaceholder")
        instituteImageView.sd_cancelCurrentImageLoad()

        if let imageURL,
           !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let url = URL(string: imageURL) {
            instituteImageView.sd_setImage(with: url, placeholderImage: placeholderImage)
        } else {
            instituteImageView.image = placeholderImage
        }
    }

    private func applyShadow() {
        layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(
            roundedRect: mainView.frame,
            cornerRadius: mainView.layer.cornerRadius
        ).cgPath
    }
}

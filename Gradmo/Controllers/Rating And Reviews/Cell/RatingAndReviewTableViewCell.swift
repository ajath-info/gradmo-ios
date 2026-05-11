//
//  RatingAndReviewTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 11/04/26.
//

import UIKit

struct RatingAndReviewItem {
    let userName: String
    let ratingText: String
    let reviewDate: String
    let reviewText: String
    let userImage: UIImage?
}

class RatingAndReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var ReviewContextlabel: UILabel!
    @IBOutlet weak var ReviewCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

private extension RatingAndReviewTableViewCell {
    func setupUI() {
        mainView.layer.cornerRadius = 12
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill

        userNameLabel.font = UIFont.GilroySemiBold(ofSize: 14)
        ReviewCountLabel.font = UIFont.GilroyMedium(ofSize: 11)
        reviewDateLabel.font = UIFont.GilroyMedium(ofSize: 11)
        ReviewContextlabel.font = UIFont.GilroyRegular(ofSize: 11)

    }
}

extension RatingAndReviewTableViewCell {
    func configure(with item: RatingAndReviewItem) {
        userNameLabel.text = item.userName
        ReviewCountLabel.text = item.ratingText
        reviewDateLabel.text = item.reviewDate
        ReviewContextlabel.text = item.reviewText
        userImageView.image = item.userImage
    }
}

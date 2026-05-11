//
//  SearchInstituteTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 29/03/26.
//

import UIKit
import SDWebImage

class SearchInstituteTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var instituteImageView: UIImageView!
    @IBOutlet weak var instituteRatingLabel: UILabel!
    @IBOutlet weak var instituteNameLabel: UILabel!
    @IBOutlet weak var instituteAddressLabel: UILabel!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var offlineImageView: UIImageView!
    @IBOutlet weak var hybridImageView: UIImageView!
    @IBOutlet weak var idNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 12
        instituteImageView.layer.cornerRadius = instituteImageView.frame.height / 2
        instituteImageView.clipsToBounds = true
        instituteNameLabel.font = UIFont.GilroyBold(ofSize: 12)
        instituteAddressLabel.font = UIFont.GilroyRegular(ofSize: 10)
        instituteRatingLabel.font = UIFont.GilroyBold(ofSize: 8)
        idNumberLabel.font = UIFont.GilroyMedium(ofSize: 8)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        instituteImageView.sd_cancelCurrentImageLoad()
        instituteImageView.image = UIImage(named: "institutePlaceholder")
    }
    
}

extension SearchInstituteTableViewCell {
    func configure(name: String,
                   address: String,
                   rating: String,
                   instituteID: String,
                   imageURL: String?,
                   placeholderImage: UIImage?,
                   showsOnline: Bool,
                   showsOffline: Bool,
                   showsHybrid: Bool) {
        instituteNameLabel.text = name
        instituteAddressLabel.text = address
        instituteRatingLabel.text = rating
        idNumberLabel.text = instituteID
        if let imageURL,
           !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let url = URL(string: imageURL) {
            instituteImageView.sd_setImage(with: url, placeholderImage: placeholderImage)
        } else {
            instituteImageView.image = placeholderImage
        }
        onlineImageView.isHidden = !showsOnline
        offlineImageView.isHidden = !showsOffline
        hybridImageView.isHidden = !showsHybrid
    }
}

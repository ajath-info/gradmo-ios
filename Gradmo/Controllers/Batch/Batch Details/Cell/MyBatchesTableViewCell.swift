//
//  MyBatchesTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 28/03/26.
//

import UIKit
import SDWebImage

class MyBatchesTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var batchImageView: UIImageView!
    @IBOutlet weak var batchName: UILabel!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var rightArrowButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 12
        batchImageView.layer.cornerRadius = self.batchImageView.bounds.height/2
        rightArrowButton.isUserInteractionEnabled = false
        selectionStyle = .none
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        batchImageView.sd_cancelCurrentImageLoad()
        batchImageView.image = UIImage(named: "institutePlaceholder")
        batchName.text = nil
        teacherName.text = nil
        timingLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension MyBatchesTableViewCell{
    func setupUI(){
        batchName.font = UIFont.GilroyBold(ofSize: 12)
        teacherName.font = UIFont.GilroyMedium(ofSize: 12)
        timingLabel.font = UIFont.GilroyMedium(ofSize: 11)
    }

    func configure(batchName: String, teacherName: String, timing: String, image: UIImage?, imageURL: String? = nil) {
        self.batchName.text = batchName
        self.teacherName.text = teacherName
        self.timingLabel.text = timing

        let placeholderImage = image ?? UIImage(named: "institutePlaceholder")
        if let imageURL,
           !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let url = URL(string: imageURL) {
            self.batchImageView.sd_setImage(with: url, placeholderImage: placeholderImage)
        } else {
            self.batchImageView.image = placeholderImage
        }
    }
}

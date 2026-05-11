//
//  VideoLecturesTableViewCell.swift
//  swift
//
//  Created by Rishabh   on 10/04/26.
//

import UIKit

class VideoLecturesTableViewCell: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        videoImageView.layer.cornerRadius = 12
        videoImageView.clipsToBounds = true

        let cardView = contentView.subviews.first
        cardView?.layer.cornerRadius = 12
        cardView?.layer.masksToBounds = true
        cardView?.layer.borderWidth = 1
        cardView?.layer.borderColor = UIColor.systemGray5.cgColor
        cardView?.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with item: VideoLectureItem) {
        titleLabel.text = item.title
        durationLabel.text = item.duration
        dateLabel.text = item.date
        videoImageView.image = UIImage(systemName: item.imageName)
        videoImageView.tintColor = .systemRed
    }
    
}

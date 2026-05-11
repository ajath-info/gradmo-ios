//
//  NotificationTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 08/05/26.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let cardView = contentView.subviews.first
        cardView?.layer.cornerRadius = 10
        cardView?.layer.masksToBounds = true
        cardView?.backgroundColor = .white

        notificationImageView.layer.cornerRadius = 12
        notificationImageView.clipsToBounds = true
        notificationLabel.font = UIFont.GilroyRegular(ofSize: 12)
        notificationTimeLabel.font = UIFont.GilroyRegular(ofSize: 10)
        notificationTimeLabel.textColor = UIColor(hex: "#7A7A7A")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

    func configure(with item: NotificationItem) {
        notificationLabel.text = item.message
        notificationTimeLabel.text = item.timeText
        notificationLabel.font = item.isRead ? UIFont.GilroyRegular(ofSize: 12) : UIFont.GilroySemiBold(ofSize: 12)
        notificationLabel.textColor = item.isRead ? UIColor(hex: "#4B5563") : UIColor(hex: "#050302")

        notificationImageView.image = item.image
        notificationImageView.tintColor = item.tintColor
        notificationImageView.backgroundColor = item.backgroundColor
    }
    
}

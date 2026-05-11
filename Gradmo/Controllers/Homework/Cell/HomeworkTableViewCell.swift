//
//  HomeworkTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 10/05/26.
//

import UIKit

class HomeworkTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var homeworkImageView: UIImageView!
    @IBOutlet weak var homeworkTitleLabel: UILabel!
    @IBOutlet weak var homeworkContentLabel: UILabel!
    @IBOutlet weak var homeworkDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        mainView.layer.cornerRadius = 12
        mainView.clipsToBounds = true
        homeworkImageView.layer.cornerRadius = 8
        homeworkImageView.clipsToBounds = true
        homeworkTitleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        homeworkContentLabel.font = .systemFont(ofSize: 13, weight: .regular)
        homeworkDateLabel.font = .systemFont(ofSize: 12, weight: .medium)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        homeworkImageView.image = UIImage(named: "institutePlaceholder")
        homeworkTitleLabel.text = nil
        homeworkContentLabel.text = nil
        homeworkDateLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
    }
    
}

extension HomeworkTableViewCell {
    func configure(with item: HomeworkItem) {
        homeworkImageView.image = item.image ?? UIImage(named: "institutePlaceholder")
        homeworkTitleLabel.text = item.title
        homeworkContentLabel.text = item.content
        homeworkDateLabel.text = item.dateText
    }
}

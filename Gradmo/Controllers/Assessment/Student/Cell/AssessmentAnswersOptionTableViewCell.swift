//
//  AssessmentAnswersOptionTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 22/04/26.
//

import UIKit

class AssessmentAnswersOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var optionNumberLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        MainView.layer.cornerRadius = 12
        MainView.layer.masksToBounds = true
        MainView.layer.borderWidth = 1
        MainView.layer.borderColor = UIColor.systemGray5.cgColor

        optionNumberLabel.font = UIFont.GilroyBold(ofSize: 20)
        answerLabel.font = UIFont.GilroyMedium(ofSize: 16)
        answerLabel.numberOfLines = 0
        answerLabel.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(optionNumber: String, answer: String, isSelected: Bool, isCorrect: Bool) {
        optionNumberLabel.text = optionNumber
        answerLabel.text = answer

        if isCorrect {
            MainView.layer.borderColor = UIColor.systemGreen.cgColor
            grayView.backgroundColor = UIColor.systemGreen
        } else if isSelected {
            let themeColor = Colors.themeColor ?? UIColor(hex: "#0066FF")
            MainView.layer.borderColor = themeColor.cgColor
            grayView.backgroundColor = themeColor
        } else {
            MainView.layer.borderColor = UIColor.systemGray5.cgColor
            grayView.backgroundColor = UIColor(hex: "#505050")
        }
    }
    
}

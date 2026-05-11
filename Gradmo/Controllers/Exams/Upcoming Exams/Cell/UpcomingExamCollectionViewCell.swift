//
//  UpcomingExamCollectionViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 13/04/26.
//

import UIKit

class UpcomingExamCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var assessmentImageView: UIImageView!
    @IBOutlet weak var assessmentTitle: UILabel!
    @IBOutlet weak var assessmentQuestionsLabel: UILabel!
    @IBOutlet weak var assessmentDurationLabel: UILabel!
    @IBOutlet weak var assessmentCompleteBy: UILabel!
    @IBOutlet weak var subjectTagLabel: UILabel!
    @IBOutlet weak var gradeTagLabel: UILabel!
    @IBOutlet weak var startAssessmentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = false

        mainView.layer.cornerRadius = 12
        assessmentImageView.layer.cornerRadius = 16
        assessmentImageView.clipsToBounds = true

        subjectTagLabel.layer.cornerRadius = self.subjectTagLabel.frame.height/2
        subjectTagLabel.layer.masksToBounds = true
        subjectTagLabel.textColor = UIColor(hex: "#0091FF")
        subjectTagLabel.layer.borderColor = subjectTagLabel.textColor.cgColor
        subjectTagLabel.layer.borderWidth = 1
        
        gradeTagLabel.layer.cornerRadius = self.gradeTagLabel.frame.height/2
        gradeTagLabel.layer.masksToBounds = true
        gradeTagLabel.textColor = UIColor(hex: "#FF7300")
        gradeTagLabel.layer.borderColor = gradeTagLabel.textColor.cgColor
        gradeTagLabel.layer.borderWidth = 1
        
        assessmentTitle.font = UIFont.GilroyBold(ofSize: 18)
        assessmentQuestionsLabel.font = UIFont.GilroyRegular(ofSize: 14)
        assessmentDurationLabel.font = UIFont.GilroyRegular(ofSize: 14)
        assessmentCompleteBy.font = UIFont.GilroyRegular(ofSize: 14)

        startAssessmentButton.layer.cornerRadius = 12
        startAssessmentButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        subjectTagLabel.layer.cornerRadius = subjectTagLabel.bounds.height / 2
        gradeTagLabel.layer.cornerRadius = gradeTagLabel.bounds.height / 2
    }

    func configure(with exam: UpcomingExamItem) {
        assessmentImageView.image = exam.image
        assessmentTitle.text = exam.title
        assessmentQuestionsLabel.text = "\(exam.questionCount)"
        assessmentDurationLabel.text = exam.duration
        assessmentCompleteBy.text = exam.completeBy
        subjectTagLabel.text = exam.subject
        gradeTagLabel.text = exam.grade
        startAssessmentButton.setTitle(exam.buttonTitle, for: .normal)
    }
}

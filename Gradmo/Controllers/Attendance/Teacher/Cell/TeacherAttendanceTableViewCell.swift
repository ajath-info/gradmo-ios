//
//  TeacherAttendanceTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 06/05/26.
//

import UIKit

enum TeacherAttendanceMark {
    case present
    case absent
    case unmarked
}

class TeacherAttendanceTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var tickMarkButton: UIButton!
    @IBOutlet weak var crossMarkButton: UIButton!

    var onMarkChanged: ((TeacherAttendanceMark) -> Void)?
    private var selectedMark: TeacherAttendanceMark = .unmarked
    private let tickColor = UIColor(hex: "#DDFFD1")
    private let crossColor = UIColor(hex: "#FBE5E5")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupAttendanceButton(tickMarkButton, borderColor: tickColor)
        setupAttendanceButton(crossMarkButton, borderColor: crossColor)
        studentImageView.clipsToBounds = true
        applySelectedMark()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        studentImageView.layer.cornerRadius = studentImageView.bounds.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onMarkChanged = nil
        configure(number: 0, studentName: "", image: nil, mark: .unmarked)
    }

    func configure(number: Int, studentName: String, image: UIImage?, mark: TeacherAttendanceMark) {
        numberLabel.text = "\(number)"
        studentNameLabel.text = studentName
        studentImageView.image = image ?? UIImage(named: "student_placeholder")
        selectedMark = mark
        applySelectedMark()
    }
    
    @IBAction func crossButtonTapped(_ sender: UIButton!){
        selectedMark = selectedMark == .absent ? .unmarked : .absent
        applySelectedMark()
        onMarkChanged?(selectedMark)
    }
    
    @IBAction func tickButtonTapped(_ sender: UIButton!){
        selectedMark = selectedMark == .present ? .unmarked : .present
        applySelectedMark()
        onMarkChanged?(selectedMark)
    }
    
}

private extension TeacherAttendanceTableViewCell {
    func setupAttendanceButton(_ button: UIButton, borderColor: UIColor) {
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor.cgColor
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.GilroyBold(ofSize: 17)
    }

    func applySelectedMark() {
        tickMarkButton.backgroundColor = selectedMark == .present ? tickColor : .clear
        crossMarkButton.backgroundColor = selectedMark == .absent ? crossColor : .clear

        tickMarkButton.layer.borderColor = tickColor.cgColor
        crossMarkButton.layer.borderColor = crossColor.cgColor
    }
}

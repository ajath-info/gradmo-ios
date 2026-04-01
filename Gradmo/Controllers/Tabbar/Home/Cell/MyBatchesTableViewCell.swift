//
//  MyBatchesTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 28/03/26.
//

import UIKit

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
        batchImageView.layer.cornerRadius = batchImageView.frame.height/2
        rightArrowButton.isUserInteractionEnabled = false
        selectionStyle = .none
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension MyBatchesTableViewCell{
    func setupUI(){
        batchName.font = UIFont.GilroyBold(ofSize: 12)
        teacherName.font = UIFont.GilroyMedium(ofSize: 12)
        timingLabel.font = UIFont.GilroyMedium(ofSize: 12)
    }

    func configure(batchName: String, teacherName: String, timing: String, image: UIImage?) {
        self.batchName.text = batchName
        self.teacherName.text = teacherName
        self.timingLabel.text = timing
        self.batchImageView.image = image
    }
}

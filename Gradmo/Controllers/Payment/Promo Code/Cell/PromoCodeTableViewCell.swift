//
//  PromoCodeTableViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 25/04/26.
//

import UIKit

class PromoCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var promoCodeLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.borderColor = UIColor.theme.cgColor
        mainView.layer.borderWidth = 1
        mainView.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    func configure(with promoCode: PromoCode) {
        promoCodeLabel.text = promoCode.code
    }
}

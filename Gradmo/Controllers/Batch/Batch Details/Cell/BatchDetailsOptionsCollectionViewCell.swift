//
//  BatchDetailsOptionsCollectionViewCell.swift
//  Gradmo
//
//  Created by Philanderer on 10/04/26.
//

import UIKit

class BatchDetailsOptionsCollectionViewCell: UICollectionViewCell {

    private enum Constants {
        static let blinkAnimationKey = "liveDotBlinkAnimation"
    }

    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var optionNameLabel: UILabel!
    @IBOutlet weak var greenDotImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopBlinkingIndicator()
        greenDotImageView.isHidden = true
    }

}

extension BatchDetailsOptionsCollectionViewCell {
    func setupUI() {
        contentView.clipsToBounds = false
        clipsToBounds = false
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.white

        optionImageView.contentMode = .scaleAspectFit
        optionNameLabel.font = UIFont.GilroyBold(ofSize: 15)
        optionNameLabel.textAlignment = .center
        optionNameLabel.numberOfLines = 0
        optionNameLabel.lineBreakMode = .byWordWrapping
        greenDotImageView.isHidden = true
    }

    func configure(title: String, image: UIImage? = nil, showsIndicator: Bool = false) {
        optionNameLabel.text = title
        optionImageView.image = image
        optionImageView.isHidden = image == nil
        greenDotImageView.isHidden = !showsIndicator

        showsIndicator ? startBlinkingIndicator() : stopBlinkingIndicator()
    }

    private func startBlinkingIndicator() {
        greenDotImageView.layer.removeAnimation(forKey: Constants.blinkAnimationKey)
        greenDotImageView.alpha = 1

        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1, 1, 0, 0]
        animation.keyTimes = [0, 0.6667, 0.6668, 1]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        greenDotImageView.layer.add(animation, forKey: Constants.blinkAnimationKey)
    }

    private func stopBlinkingIndicator() {
        greenDotImageView.layer.removeAnimation(forKey: Constants.blinkAnimationKey)
        greenDotImageView.alpha = 1
    }

    private func applyShadow() {
        layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(
            roundedRect: contentView.bounds,
            cornerRadius: 12
        ).cgPath
    }
}

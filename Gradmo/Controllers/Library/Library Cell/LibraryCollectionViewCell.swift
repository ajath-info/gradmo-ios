//
//  LibraryCollectionViewCell.swift
//  swift
//
//  Created by Rishabh   on 10/04/26.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentImageView.tintColor = .systemOrange
    }
    
    func configure(with item: LibraryItem) {
        headingLabel.text = item.title
        sizeLabel.text = item.size
        datelabel.text = item.dateAdded
        contentImageView.image = UIImage(systemName: item.imageName)
    }
}

//
//  CollectionViewExtension.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation
import UIKit

typealias CollectionCellClass = UICollectionViewCell.Type

extension UICollectionView {
    
    // Register collection view cell using nib name and reuse identifier
    func registerCellWithoutClassName(_ nibName: String, forCellWithReuseIdentifier reuseIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // Register collection view cell using its class type
    func registerXib(_ cellClass: CollectionCellClass, forCellWithReuseIdentifier identifier: String? = nil) {
        let cellIdentifier = identifier ?? String(describing: cellClass)
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
}

//
//  TableViewExtension.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation
import UIKit

typealias TableCellClass = UITableViewCell.Type

extension UITableView {
    func registerCellWithoutClassName(_ nibName: String, forCellReuseIdentifier reuseIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: reuseIdentifier)
        
    }
    func registerXib(_ cellClass: TableCellClass, forCellReuseIdentifier identifier: String? = nil) {
        let cellIdentifier = identifier ?? String(describing: cellClass)
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: cellIdentifier)
    }
}



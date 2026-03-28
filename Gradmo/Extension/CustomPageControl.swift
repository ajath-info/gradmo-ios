//
//  CustomPageControl.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 28/08/25.
//


import UIKit

class CustomPageControl: UIStackView {
    private var dots: [UIView] = []

    var numberOfPages: Int = 0 {
        didSet { setupDots() }
    }

    var currentPage: Int = 0 {
        didSet { updateDotStyles() }
    }

    var selectedColor: UIColor = UIColor(red: 85/255, green: 174/255, blue: 255/255, alpha: 1) // light blue
    var deselectedColor: UIColor = UIColor(red: 85/255, green: 174/255, blue: 255/255, alpha: 0.3) // light faded blue

    private func setupDots() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        for index in 0..<numberOfPages {
            let dot = UIView()
            dot.backgroundColor = deselectedColor
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 4
            dot.clipsToBounds = true

            let widthConstraint = dot.widthAnchor.constraint(equalToConstant: 8)
            widthConstraint.identifier = "width"
            widthConstraint.isActive = true

            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true

            addArrangedSubview(dot)
            dots.append(dot)
        }

        spacing = 8
        alignment = .center
        updateDotStyles()
    }

    private func updateDotStyles() {
        for (index, dot) in dots.enumerated() {
            if let widthConstraint = dot.constraints.first(where: { $0.identifier == "width" }) {
                if index == currentPage {
                    dot.backgroundColor = selectedColor
                    dot.layer.cornerRadius = 4
                    widthConstraint.constant = 24 // pill shape
                } else {
                    dot.backgroundColor = deselectedColor
                    dot.layer.cornerRadius = 4
                    widthConstraint.constant = 8 // normal dot
                }
            }
        }

        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}


//
//  GradientExtension.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation

import UIKit
enum GradientType {
    case vertical
    case horizontal
    case diagonalTopLeftToBottomRight
    case diagonalTopRightToBottomLeft
}



extension UIView {
    
    static let kLayerNameGradientBorder = "GradientBorderLayer"
    
    func setGradientBorder1(
        width: CGFloat,
        colors: [UIColor],
        radius: CGFloat,
        startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 0.0)
    ) {
        removeGradientBorder()
        
        let border = CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        border.name = UIView.kLayerNameGradientBorder
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        
        layer.cornerRadius = radius
        border.mask = mask
        
        layer.addSublayer(border)
    }
    
    func removeGradientBorder() {
        layer.sublayers?.removeAll(where: { $0.name == UIView.kLayerNameGradientBorder })
    }
    
    
    
    
    //    func setGradientVerticalBackgroundView(colorTop: UIColor, colorBottom: UIColor) {
    //        let colorTop = colorTop.cgColor
    //        let colorBottom = colorBottom.cgColor
    //        let gradientLayer = CAGradientLayer()
    //        gradientLayer.name = "gradient"
    //        gradientLayer.colors = [colorTop, colorBottom]
    //        gradientLayer.locations = [0.3, 0.5]//0.2,0.1
    //        gradientLayer.frame = self.bounds
    //        self.layer.insertSublayer(gradientLayer, at:0)
    //    }
    
    func setGradientVerticalBackgroundView(colorTop: UIColor, colorBottom: UIColor) {
        // Storyboard color clear karo
        self.backgroundColor = .clear
        
        // Purane gradient layers hatao
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func applyVerticalGradient(colors: [UIColor]) {
        // Purane gradient layers hata do
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)   // Top-center
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)   // Bottom-center
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    func removeVerticalGradient() {
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }
    
    func applySurroundShadow(){
        layer.masksToBounds = false
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(hex: "#61A0F0").cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
      }
    
}


extension UILabel {
    func applyGradientText(colors: [UIColor]) {
        self.textColor = .clear   // make text transparent

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        if let oldLayer = (layer.sublayers?.first { $0.name == "gradientTextLayer" }) {
            oldLayer.removeFromSuperlayer()
        }

        gradientLayer.name = "gradientTextLayer"
        gradientLayer.mask = self.layer

        superview?.layer.addSublayer(gradientLayer)
        superview?.layer.masksToBounds = true
    }
}

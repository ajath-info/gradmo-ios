//
//  S3Manager.swift
//  Motivaid
//
//  Created by Rishabh   on 05/12/25.
//

import UIKit
import SDWebImage

class S3Short {

    /// Upload image using your OLD S3 helper (short version)
    static func uploadImage(_ image: UIImage?,
                            folder: String,
                            userName: String,
                            view: UIView,
                            completion: @escaping (String?) -> Void) {

        guard let data = image?.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }

        S3BucketHelper.uploadImageOnAws(
            imgdata: data,
            publisherImages: folder,
            userName: userName,
            view: view
        ) { key, error in
            completion(key)   // returns only the key
        }
    }

    /// Load image in ANY UIImageView using your public URL generator
//    static func loadImage(key: String?, into imageView: UIImageView) {
//           guard let key = key else { return }
//
//           let urlString = "https://dev-motivaid.s3.amazonaws.com/\(key)"
//
//           imageView.sd_setImage(with: URL(string: urlString)) { image, _, _, _ in
//               guard image != nil else { return }
//               
//               // FADE ANIMATION
//               imageView.alpha = 0
//               UIView.animate(withDuration: 0.3) {
//                   imageView.alpha = 1
//               }
//           }
//       }
    
    
    static func loadImage(key: String?, into imageView: UIImageView) {
        guard let key = key else { return }
        
        let urlString = "https://dev-motivaid.s3.amazonaws.com/\(key)"
        
        // show skeleton
        imageView.showSkeleton()

        imageView.sd_setImage(with: URL(string: urlString)) { image, _, _, _ in
            
            // hide skeleton
            imageView.hideSkeleton()

            guard image != nil else { return }

            // fade animation
            imageView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                imageView.alpha = 1
            }
        }
    }

    static func loadImageWithoutSkeleton(key: String?, into imageView: UIImageView) {
        guard let key = key else { return }
        
        let urlString = "https://dev-motivaid.s3.amazonaws.com/\(key)"
      
        imageView.sd_setImage(with: URL(string: urlString)) { image, _, _, _ in
      
            guard image != nil else { return }

            // fade animation
            imageView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                imageView.alpha = 1
            }
        }
    }
    
}



extension UIView {
    func showSkeleton() {
        let shimmerTag = 999999

        if self.viewWithTag(shimmerTag) != nil { return }

        self.layoutIfNeeded()

        let skeletonView = UIView()
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        skeletonView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        skeletonView.layer.cornerRadius = self.layer.cornerRadius
        skeletonView.clipsToBounds = true
        skeletonView.tag = shimmerTag

        self.addSubview(skeletonView)

        NSLayoutConstraint.activate([
            skeletonView.topAnchor.constraint(equalTo: self.topAnchor),
            skeletonView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            skeletonView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            skeletonView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        self.layoutIfNeeded()

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.lightGray.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.frame = skeletonView.bounds

        skeletonView.layer.addSublayer(gradientLayer)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.2
        animation.repeatCount = .infinity

        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }


    func hideSkeleton() {
        self.viewWithTag(999999)?.removeFromSuperview()
    }
}

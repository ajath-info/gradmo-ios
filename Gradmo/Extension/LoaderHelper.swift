//
//  LoaderHelper.swift
//  HLS
//
//  Created by Hrithik on 24/08/23.
//


import Foundation
import UIKit
import MBProgressHUD

class LoaderHelper : NSObject {
    
    var progressHud = MBProgressHUD()
    static let shared = LoaderHelper()
    
    //MARK: - START LOADER
    func startLoader(_ view:UIView, backGrounColor: UIColor = .clear, isTextMsg : Bool = false) {
        if progressHud.superview != nil {
            progressHud.hide(animated: false)
        }
        if #available(iOS 9.0, *) {
            UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color =  .white
        }else {
//            progressHud.activityIndicatorColor = UIColor.white
        }
        progressHud = MBProgressHUD.showAdded(to: view, animated: true)
        progressHud.bezelView.color = Colors.darkBlue
        progressHud.bezelView.style = .solidColor
        progressHud.backgroundView.color = backGrounColor
        progressHud.label.text =  isTextMsg ? "Please Wait..." : ""
        progressHud.label.textColor = .white
        progressHud.show(animated: true)
    }
    
    //MARK: - STOP LOADER
    func stopLoader() {
        progressHud.hide(animated: true)
    }
}

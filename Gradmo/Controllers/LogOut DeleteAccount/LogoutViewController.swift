//
//  LogoutViewController.swift
//  Gradmo
//
//  Created by Philanderer on 23/03/26.
//

import UIKit

class LogoutViewController: UIViewController {
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var mainView:UIView!
    
    var isComingFrom = "Logout"
    var onConfirmLogout: (() -> Void)?
    var onConfirmDeleteAccount: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainView.layer.cornerRadius = 12
        yesButton.layer.cornerRadius = 12
        noButton.layer.cornerRadius = 12
        if isComingFrom == "logOut"{
            logoutLabel.text = "Are you sure you want to logout from your account?"
        }else if isComingFrom == "deleteAccount"{
            logoutLabel.text = "Are you sure you want to delete your account permanently?"
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton!){
        self.dismiss(animated: true)
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton!){
        if isComingFrom == "logOut" {
            dismiss(animated: true) {
                self.onConfirmLogout?()
            }
        } else if isComingFrom == "deleteAccount" {
            dismiss(animated: true) {
                self.onConfirmDeleteAccount?()
            }
        } else {
            showToastSafely("Under Development")
        }
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton!){
        self.dismiss(animated: true)
    }
    
}

extension LogoutViewController{
    func setupUI(){
        logoutLabel.font = UIFont.GilroyRegular(ofSize: 15)
        yesButton.titleLabel?.font = UIFont.GilroySemiBold(ofSize: 15)
        noButton.titleLabel?.font = UIFont.GilroySemiBold(ofSize: 15)
    }
}

//
//  SideMenuViewController.swift
//  Gradmo
//
//  Created by Philanderer on 22/03/26.
//

import UIKit
import SDWebImage

private struct ActionResponse: Decodable {
    let isSuccess: Bool
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case status
        case msg
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let statusString = try? container.decode(String.self, forKey: .status) {
            isSuccess = statusString.lowercased() == "true" || statusString == "1"
        } else if let statusBool = try? container.decode(Bool.self, forKey: .status) {
            isSuccess = statusBool
        } else if let statusInt = try? container.decode(Int.self, forKey: .status) {
            isSuccess = statusInt == 1
        } else {
            isSuccess = false
        }

        message = (try? container.decode(String.self, forKey: .msg))
            ?? (try? container.decode(String.self, forKey: .message))
    }
}

class SideMenuViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var myBatchesLabel: UILabel!
    @IBOutlet weak var editProfileLabel: UILabel!
    @IBOutlet weak var paymentHistoryLabel: UILabel!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var aboutAppLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var deleteAccountLabel: UILabel!
    @IBOutlet weak var shareAppLabel: UILabel!
    @IBOutlet weak var updatePasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    @IBAction func viewProfileButtonTapped(_ sender: UIButton!){
        if let homeVC = self.parent as? HomeViewController {
               homeVC.hideSideMenu()
               homeVC.tabBarController?.selectedIndex = 4
           }
    }
    
    @IBAction func homeButtonTapped(_ sender: UIButton!){
        if let homeVC = self.parent as? HomeViewController {
               homeVC.hideSideMenu()
               homeVC.tabBarController?.selectedIndex = 0
           }
    }
    
    @IBAction func myBatchesButtonTapped(_ sender: UIButton!){
        showToastSafely("Under Development")
    }
    
    @IBAction func editProfileButtonTapped(_ sender: UIButton!){
        guard let homeVC = self.parent as? HomeViewController else { return }

        homeVC.hideSideMenu()

        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let updateProfileVC = storyboard.instantiateViewController(withIdentifier: "UpdateProfileViewController") as? UpdateProfileViewController
                
        else {
            return
        }

        let role = UserCache.getUserRole()
        updateProfileVC.selectedRole = role
        updateProfileVC.isEditingFromSideMenu = true
        updateProfileVC.hidesBottomBarWhenPushed = true
        updateProfileVC.authUserData = AuthUserData(
            fullName: UserCache.fullName(),
            email: UserCache.email_id(),
            phone: UserCache.phone(),
            studentId: role == .student ? UserCache.userID() : "",
            teacherId: role == .teacher ? UserCache.userID() : "",
            instituteId: role == .institute ? UserCache.userID() : "",
            imageURL: UserCache.profileImageURL(),
            accessToken: UserCache.token(),
            userRole: role
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            homeVC.navigationController?.pushViewController(updateProfileVC, animated: true)
        }
    }
    
    @IBAction func paymentHistoryButtonTapped(_ sender: UIButton!){
        showToastSafely("Under Development")
    }
    
    @IBAction func privacyPolicyButtonTapped(_ sender: UIButton!){
        showToastSafely("Under Development")
    }
    
    @IBAction func aboutAppButtonTapped(_ sender: UIButton!){
        showToastSafely("Under Development")
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton!){
        let vc = storyboard?.instantiateViewController(withIdentifier: "LogoutViewController") as! LogoutViewController
        vc.isComingFrom = "logOut"
        vc.onConfirmLogout = { [weak self] in
            self?.logoutUser()
        }
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton!){
        let vc = storyboard?.instantiateViewController(withIdentifier: "LogoutViewController") as! LogoutViewController
        vc.isComingFrom = "deleteAccount"
        vc.onConfirmDeleteAccount = { [weak self] in
            self?.deleteAccount()
        }
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    @IBAction func shareAppButtonTapped(_ sender: UIButton!){
        showToastSafely("Under Development")
    }
    
    @IBAction func updatePasswordButtonTapped(_ sender: UIButton!){
        showToastSafely("Under Development")
    }
}

    private extension SideMenuViewController {

        func setupUI() {
            
            userNameLabel.font = UIFont.GilroyBold(ofSize: 18)
            homeLabel.font = UIFont.GilroyBold(ofSize: 15)
            myBatchesLabel.font = UIFont.GilroyBold(ofSize: 15)
            editProfileLabel.font = UIFont.GilroyBold(ofSize: 15)
            paymentHistoryLabel.font = UIFont.GilroyBold(ofSize: 15)
            privacyPolicyLabel.font = UIFont.GilroyBold(ofSize: 15)
            aboutAppLabel.font = UIFont.GilroyBold(ofSize: 15)
            logoutLabel.font = UIFont.GilroyBold(ofSize: 15)
            deleteAccountLabel.font = UIFont.GilroyBold(ofSize: 15)
            shareAppLabel.font = UIFont.GilroyBold(ofSize: 15)
            updatePasswordLabel.font = UIFont.GilroyBold(ofSize: 15)
            
            view.backgroundColor = .clear

            userNameLabel.text = UserCache.fullName()
            userProfilePic.layer.cornerRadius = userProfilePic.frame.height / 2
            userProfilePic.clipsToBounds = true

            if let imageURL = URL(string: UserCache.profileImageURL()), !UserCache.profileImageURL().isEmpty {
                userProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "profilePic"))
            } else {
                userProfilePic.image = UIImage(named: "profilePic")
            }
        }

        func logoutUser() {
            let userId = UserCache.userID()
            guard !userId.isEmpty else {
                showToastSafely("Unable to logout. Missing user details.")
                return
            }

            guard !UserCache1.authtoken().isEmpty else {
                showToastSafely("Session expired. Please sign in again.")
                return
            }

            LoaderManager.shared.show()

            let key: String
            switch UserCache.getUserRole() {
            case .student:
                key = "student_id"
            case .teacher:
                key = "teacher_id"
            case .institute:
                key = "institute_id"
            }

            let params: [String: Any] = [
                key: userId
            ]

            Task { [weak self] in
                guard let self else { return }

                do {
                    let response: ActionResponse = try await APIManager.shared.post(
                        Constant.baseUrl + API.logoutAPI,
                        parameters: params,
                        expectsWrappedResponse: false
                    )

                    await MainActor.run {
                        LoaderManager.shared.hide()
                        guard response.isSuccess else {
                            self.showToastSafely(response.message ?? "Unable to logout")
                            return
                        }

                        UserCache.logout()
                        CommonClass.shared.moveToLogin()
                    }
                } catch {
                    await MainActor.run {
                        LoaderManager.shared.hide()
                        self.showToastSafely(error.localizedDescription)
                    }
                }
            }
        }

        func deleteAccount() {
            guard !UserCache1.authtoken().isEmpty else {
                showToastSafely("Session expired. Please sign in again.")
                return
            }

            LoaderManager.shared.show()

            Task { [weak self] in
                guard let self else { return }

                do {
                    let response: ActionResponse = try await APIManager.shared.post(
                        Constant.baseUrl + API.deleteAccountAPI,
                        parameters: nil,
                        expectsWrappedResponse: false
                    )

                    await MainActor.run {
                        LoaderManager.shared.hide()
                        guard response.isSuccess else {
                            self.showToastSafely(response.message ?? "Unable to delete account")
                            return
                        }

                        self.showToastSafely(response.message ?? "Account deleted successfully")
                        UserCache.logout()
                        CommonClass.shared.moveToRegisterAs()
                    }
                } catch {
                    await MainActor.run {
                        LoaderManager.shared.hide()
                        self.showToastSafely(error.localizedDescription)
                    }
                }
            }
        }
    }

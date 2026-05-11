//
//  CommonConstant.swift
//  BTYB
//
//  Created by Yogyata on 21/11/24.
//

import Foundation
import UIKit

// MARK: - CommonClass Singleton
class CommonClass: NSObject {
    static let shared = CommonClass()
    
    // MARK: - Navigation Methods
     func moveToRootViewController(_ viewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.isNavigationBarHidden = true
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
    
    func moveToHome() {
        let userType = UserCache.getUserRole()
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let tabBarVC = storyboard.instantiateViewController(
            withIdentifier: "CustomTabBarController"
        ) as! CustomTabBarController
        tabBarVC.initialUserType = userType
        moveToRootViewController(tabBarVC)
    }

//    MARK: - This is temporary go to home, make neccessary changes in the move to home.
    public func goToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomTabBarController")

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        window.rootViewController = vc
        UIView.transition(with: window,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }
    
    func moveToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = UserDefaults.standard.bool(forKey: LoginKeys.didSeeOnboarding)
            ? "RegisterAsViewController"
            : "OnboardingViewController"
        let rootVC = storyboard.instantiateViewController(withIdentifier: identifier)
        moveToRootViewController(rootVC)
    }

    func moveToLoginScreen(selectedRole: UserRole = .student) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(
            withIdentifier: "LogInViewController"
        ) as! LogInViewController
        loginViewController.selectedRole = selectedRole
        loginViewController.shouldHideCancelButton = true
        moveToRootViewController(loginViewController)
    }

    func moveToRegisterAs() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = storyboard.instantiateViewController(
            withIdentifier: "RegisterAsViewController"
        )
        moveToRootViewController(rootVC)
    }
    
    func moveToProfileCompletion() {
        let role = UserCache.getUserRole()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = storyboard.instantiateViewController(
            withIdentifier: "CompleteProfileViewController"
        ) as! CompleteProfileViewController
        rootVC.selectedRole = role
        moveToRootViewController(rootVC)
    }

    
    func getDay(date: String) -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.dateStyle = .short
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.doesRelativeDateFormatting = true
        relativeDateFormatter.locale = Locale(identifier: "en_US")
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        if let date = inputFormatter.date(from: date) {
            print(relativeDateFormatter.string(from: date))
            return relativeDateFormatter.string(from: date)

        }
        return ""
    }
    func getDay1(date: String) -> String {

        // 1️⃣ Input formatter for ISO string
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // 2️⃣ Output formatter (12-hour AM/PM)
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "hh:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.timeZone = TimeZone.current   // local time

        if let parsedDate = inputFormatter.date(from: date) {
            return outputFormatter.string(from: parsedDate)
        }

        return ""
    }

    func alert_action(_ message : String , title : String = "", VC: UIViewController, completionBlock: @escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            completionBlock()
        }))
        VC.present(alert, animated: true, completion: nil)
    }
    func alert_actionOK(_ message : String , title : String = "", VC: UIViewController, completionBlock: @escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (action) in
            completionBlock()
        }))
        VC.present(alert, animated: true, completion: nil)
    }
    
    func alert_actionBlock(_ message: String,title: String = "",VC: UIViewController,yesCompletion: @escaping () -> Void,noCompletion: (() -> Void)? = nil // "No" ka optional completion
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // "No" Button: Execute noCompletion block if available
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            noCompletion?()  // Agar completion pass kiya ho toh execute karo
        }))
        
        // "Yes" Button: Execute yesCompletion block
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            yesCompletion()
        }))
        
        VC.present(alert, animated: true, completion: nil)
    }
    
    
    
}

// MARK: - ToastMsg
struct ToastMsg {
    static let logoutMsgAlert  =   "Are you sure, you want to log out?"
    static let deleteMsgAlert  =   "Are you sure, you want to delete Account?"
    static let reportReelMsgAlert  =   "Are you sure, you want to report this reel?"
    static let userBlockMsgAlert  =   "Are you sure, you want to block this user?"
    static let reportMsgAlert  =   "Oops! You can't report your own post"
    static let liveMsgAlert  =   "Live feature coming soon"
    static let oneTimePopUpWebAlertMsg  =   "Statement web links redirect to external websites which are not owned by BTYB"
}

// MARK: - UIViewController Extension
extension UIViewController {
    
    // MARK: - Properties
    class var storyboardID: String {
        return "\(self)"
    }
    
    // MARK: - Instantiation Method
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController()
    }
}

// MARK: - AppStoryboard Enum
enum AppStoryboard: String {
    case main = "Main"
    case home = "Home"
    
    // MARK: - Instance of UIStoryboard
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    // MARK: - View Controller Instantiation
    func viewController<T: UIViewController>(viewControllerClass: T.Type = T.self) -> T {
        let storyboardID = T.storyboardID
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID) not found in \(self.rawValue) storyboard.")
        }
        return scene
    }
    
    // MARK: - Initial View Controller
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}
extension UINavigationController {
    func getViewController<T: UIViewController>(of type: T.Type) -> UIViewController? {
        return self.viewControllers.first(where: { $0 is T })
    }
    
    func popToViewController<T: UIViewController>(of type: T.Type, animated: Bool) {
        guard let viewController = self.getViewController(of: type) else { return }
        self.popToViewController(viewController, animated: animated)
    }
}

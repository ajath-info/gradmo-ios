////
////  ZoomManager.swift
////  Motivaid
////
////  Handles Zoom Meeting SDK initialization, authentication, and meeting joining.
////  Supports both Meeting ID + passcode and direct join-URL flows.
////
//
//import UIKit
//import MobileRTC
//
//// MARK: - Zoom Credentials (replace with your actual SDK credentials)
//private enum ZoomCredentials {
//    /// Get these from marketplace.zoom.us → Your App → App Credentials
//    static let sdkKey    = "YOUR_ZOOM_SDK_KEY"
//    static let sdkSecret = "YOUR_ZOOM_SDK_SECRET"
//
//    /// Display name used when joining as a guest
//    static let displayName = "Motivaid Student"
//}
//
//// MARK: - ZoomManager
//
//final class ZoomManager: NSObject {
//
//    static let shared = ZoomManager()
//    private override init() {}
//
//    // Keeps a reference to prevent deallocation during a meeting
//    private var meetingService: MobileRTCMeetingService?
//
//    // -------------------------------------------------------------------------
//    // MARK: - SDK Initialization
//    // Call once from AppDelegate.application(_:didFinishLaunchingWithOptions:)
//    // -------------------------------------------------------------------------
//    func initializeSDK(rootViewController: UIViewController) {
//        let context = MobileRTCSDKInitContext()
//        context.domain = "zoom.us"
//        context.enableLog = false
//
//        guard MobileRTC.shared().initialize(context) else {
//            print("❌ [ZoomManager] SDK failed to initialize")
//            return
//        }
//
//        MobileRTC.shared().setMobileRTCRootController(
//            rootViewController.navigationController ?? UINavigationController(rootViewController: rootViewController)
//        )
//
//        authenticateSDK()
//        print("✅ [ZoomManager] SDK initialized")
//    }
//
//    // -------------------------------------------------------------------------
//    // MARK: - Authentication
//    // -------------------------------------------------------------------------
//    private func authenticateSDK() {
//        guard let authService = MobileRTC.shared().getAuthService() else { return }
//        authService.delegate = self
//
//        let authContext = MobileRTCSDKAuthContext()
//        authContext.jwtToken = generateJWT()
//        authService.sdkAuth(authContext)
//    }
//
//    /// Generates a signed JWT for SDK authentication.
//    /// In production, generate this on your server and fetch it via API
//    /// to keep your SDK secret out of the app binary.
//    private func generateJWT() -> String {
//        // ⚠️  SERVER-SIDE JWT GENERATION IS STRONGLY RECOMMENDED IN PRODUCTION.
//        // The implementation below is intentionally left as a placeholder.
//        // See: https://developers.zoom.us/docs/meeting-sdk/auth/#generate-an-sdk-jwt
//        return "REPLACE_WITH_JWT_FROM_YOUR_SERVER"
//    }
//
//    // -------------------------------------------------------------------------
//    // MARK: - Join Meeting by ID + Passcode
//    // -------------------------------------------------------------------------
//    func joinMeeting(
//        meetingNumber: String,
//        passcode: String,
//        displayName: String = ZoomCredentials.displayName,
//        from viewController: UIViewController,
//        completion: ((JoinResult) -> Void)? = nil
//    ) {
//        guard MobileRTC.shared().isRTCAuthorized() else {
//            completion?(.failure("Zoom SDK is not authorized yet. Please try again."))
//            return
//        }
//
//        guard let service = MobileRTC.shared().getMeetingService() else {
//            completion?(.failure("Unable to get meeting service."))
//            return
//        }
//
//        meetingService = service
//        meetingService?.delegate = self
//
//        MobileRTC.shared().setMobileRTCRootController(
//            viewController.navigationController
//            ?? UINavigationController(rootViewController: viewController)
//        )
//
//        let params = MobileRTCMeetingJoinParam()
//        params.meetingNumber = meetingNumber.replacingOccurrences(of: " ", with: "")
//        params.password      = passcode
//        params.userName      = displayName
//        params.noVideo       = false
//        params.noAudio       = false
//
//        let result = service.joinMeeting(with: params)
//
//        if result != .success {
//            let message = zoomErrorMessage(for: result)
//            completion?(.failure(message))
//        } else {
//            completion?(.success)
//        }
//    }
//
//    // -------------------------------------------------------------------------
//    // MARK: - Join via Zoom Deep Link / URL
//    // Opens the Zoom app (or Zoom website fallback) with a pre-filled join URL.
//    // -------------------------------------------------------------------------
//    func joinMeetingViaLink(_ urlString: String, from viewController: UIViewController) {
//        // Validate & open the link
//        var finalURL: URL?
//
//        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
//            finalURL = url
//        } else if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//                  let url = URL(string: encoded) {
//            finalURL = url
//        }
//
//        guard let url = finalURL else {
//            showAlert(on: viewController, title: "Invalid Link", message: "The class link appears to be invalid. Please contact your counselor.")
//            return
//        }
//
//        UIApplication.shared.open(url, options: [:]) { success in
//            if !success {
//                self.showAlert(on: viewController, title: "Zoom Not Installed",
//                               message: "Could not open Zoom. Please install the Zoom app and try again.")
//            }
//        }
//    }
//
//    // -------------------------------------------------------------------------
//    // MARK: - Helpers
//    // -------------------------------------------------------------------------
//    private func zoomErrorMessage(for result: MobileRTCMeetError) -> String {
//        switch result {
//        case .success:             return "Success"
//        case .networkUnavailable:  return "No internet connection. Please check your network."
//        case .meetingNotExist:     return "This meeting does not exist or has ended."
//        case .meetingPasswordError: return "Incorrect passcode. Please try again."
//        case .userNotFound:        return "User not found."
//        default:                   return "Unable to join the meeting. Please try again."
//        }
//    }
//
//    private func showAlert(on vc: UIViewController, title: String, message: String) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            vc.present(alert, animated: true)
//        }
//    }
//}
//
//// MARK: - Result Type
//
//extension ZoomManager {
//    enum JoinResult {
//        case success
//        case failure(String)
//    }
//}
//
//// MARK: - MobileRTCAuthDelegate
//
//extension ZoomManager: MobileRTCAuthDelegate {
//    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
//        switch returnValue {
//        case .success:
//            print("✅ [ZoomManager] SDK authenticated successfully")
//        case .keyOrSecretWrong:
//            print("❌ [ZoomManager] Auth failed – check SDK Key/Secret or JWT token")
//        default:
//            print("⚠️ [ZoomManager] Auth returned: \(returnValue.rawValue)")
//        }
//    }
//
//    func onMobileRTCAuthExpired() {
//        print("⚠️ [ZoomManager] Auth token expired – re-authenticating")
//        authenticateSDK()
//    }
//}
//
//// MARK: - MobileRTCMeetingServiceDelegate
//
//extension ZoomManager: MobileRTCMeetingServiceDelegate {
//    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
//        switch state {
//        case .connecting:
//            print("📡 [ZoomManager] Connecting to meeting…")
//        case .inMeeting:
//            print("✅ [ZoomManager] In meeting")
//        case .ended:
//            print("🔚 [ZoomManager] Meeting ended")
//        case .failed:
//            print("❌ [ZoomManager] Meeting failed")
//        default:
//            break
//        }
//    }
//
//    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
//        print("❌ [ZoomManager] Meeting error \(error.rawValue): \(message ?? "")")
//    }
//}

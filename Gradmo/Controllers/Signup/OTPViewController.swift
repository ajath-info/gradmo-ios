//
//  OTPViewController.swift
//  Gradmo
//
//  Created by Philanderer on 15/03/26.
//

import UIKit

final class OTPViewController: UIViewController {

    @IBOutlet private weak var didNotReceiveCodeLabel: UILabel!
    @IBOutlet private weak var resendButton: UIButton!
    @IBOutlet private weak var OTPTXT: AEOTPTextField!
    @IBOutlet private weak var msgLabel: UILabel!
    @IBOutlet private weak var verifyEmailLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var verifyOtpButton: UIButton!

    var context: OTPFlowContext?
    var initialExpectedOTP: String?
    var initialToastMessage: String?
    private let viewModel = OTPViewModel()
    private var expectedOTP: String?
    private var hasShownInitialToast = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupOTPField()
        expectedOTP = initialExpectedOTP
        OTPTXT.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        verifyOtpButton.applyCapsuleCornerRadius()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasShownInitialToast, let initialToastMessage, !initialToastMessage.isEmpty else {
            return
        }

        hasShownInitialToast = true
        showToastSafely(initialToastMessage)
    }
}

// MARK: - Setup

private extension OTPViewController {

    func setupUI() {
        verifyEmailLabel.font = UIFont.GilroyMedium(ofSize: 18)
        msgLabel.font = UIFont.GilroyMedium(ofSize: 12)
        didNotReceiveCodeLabel.font = UIFont.GilroyMedium(ofSize: 10)
        resendButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 10)
        verifyOtpButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 12)
        verifyOtpButton.setEnabledStyle(false)

        guard let context else {
            verifyEmailLabel.text = "Verify OTP"
            msgLabel.text = "Enter the 4 digit OTP"
            return
        }

        verifyEmailLabel.text = context.channel.titleText
        msgLabel.text = "Enter the 4 digit OTP sent to \(context.recipient)"
    }

    func setupOTPField() {
        OTPTXT.configure(with: 4)
        OTPTXT.otpDelegate = self
        OTPTXT.addTarget(self, action: #selector(otpTextChanged), for: .editingChanged)
        OTPTXT.layer.borderColor = UIColor(hex: "#060302").cgColor
        OTPTXT.layer.cornerRadius = 8
        OTPTXT.layer.masksToBounds = true
    }

    func handleVerifiedOTP() {
        guard let context else {
            showToastSafely("OTP flow is not configured")
            return
        }

        switch context.destination {
        case .home:
            UserCache.saveSelectedUserRole(context.userRole)
            CommonClass.shared.moveToHome()

        case .resetPassword:
            let viewController = storyboard?.instantiateViewController(
                withIdentifier: "ResetPasswordViewController"
            ) as! ResetPasswordViewController
            viewController.mobile = context.recipient
            viewController.selectedRole = context.userRole
            navigationController?.pushViewController(viewController, animated: true)

            case .completeProfile:
                let viewController = storyboard?.instantiateViewController(
                    withIdentifier: "CompleteProfileViewController"
                ) as! CompleteProfileViewController
                viewController.selectedRole = context.userRole
                var updatedAuthUserData = context.authUserData
                let accessToken = UserCache1.authtoken()
                if !accessToken.isEmpty {
                    updatedAuthUserData?.accessToken = accessToken
                }
                viewController.authUserData = updatedAuthUserData
                navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - Actions

extension OTPViewController {

    @objc private func otpTextChanged() {
        let count = OTPTXT.text?.count ?? 0
        verifyOtpButton.setEnabledStyle(count == 4)
    }

    @IBAction func tapOnVerifyOtpButton(_ sender: UIButton) {
        guard (OTPTXT.text ?? "").count == 4 else {
            showToastSafely("Enter valid OTP")
            return
        }

        if context?.channel == .email {
            handleVerifiedOTP()
            return
        }

        verifyOTP()
    }

    @IBAction func tapOnBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func tapOnResendButton(_ sender: UIButton) {
        sendOTPIfNeeded(isResend: true)
    }
}

// MARK: - AEOTPTextFieldDelegate

extension OTPViewController: AEOTPTextFieldDelegate {

    func didUserFinishEnter(the code: String) {
        verifyOtpButton.setEnabledStyle(code.count == 4)
    }
}

// MARK: - API

private extension OTPViewController {

    func verifyOTP() {
        guard let context else {
            showToastSafely("OTP flow is not configured")
            return
        }

        let mobile = context.authUserData?.phone.isEmpty == false
            ? context.authUserData?.phone
            : context.recipient

        guard let mobile, !mobile.isEmpty else {
            showToastSafely("Mobile number is missing")
            return
        }

        guard let otp = OTPTXT.text, otp.count == 4 else {
            showToastSafely("Enter valid OTP")
            return
        }

        LoaderManager.shared.show()
        verifyOtpButton.setEnabledStyle(false)

        let request = VerifyOTPRequest(
            mobile: mobile,
            otp: otp,
            userType: context.userRole.rawValue.lowercased()
        )

        viewModel.verifyOTP(request: request) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()
            self.verifyOtpButton.setEnabledStyle(true)

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Invalid OTP")
                    return
                }

                self.persistVerifiedSessionIfNeeded(response.data, for: context)
                self.handleVerifiedOTP()

            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func sendOTPIfNeeded(isResend: Bool = false) {
        guard let context else {
            return
        }

        LoaderManager.shared.show()

        let request: SendOTPRequest
        switch context.purpose {
        case .signup:
            guard let auth = context.authUserData,
                  !auth.fullName.isEmpty,
                  !auth.email.isEmpty,
                  !auth.phone.isEmpty else {
                LoaderManager.shared.hide()
                showToastSafely("Missing signup details for OTP")
                return
            }

            request = SendOTPRequest(
                name: auth.fullName,
                email: auth.email,
                mobile: auth.phone,
                userType: context.userRole.rawValue.lowercased()
            )

        case .forgotPassword:
            let mobile = context.authUserData?.phone.isEmpty == false
                ? context.authUserData?.phone
                : context.recipient

            guard let mobile, mobile.isValidPhoneNumber() else {
                LoaderManager.shared.hide()
                showToastSafely("Please enter a valid 10-digit mobile number")
                return
            }

            request = SendOTPRequest(
                name: nil,
                email: nil,
                mobile: mobile,
                userType: context.userRole.rawValue.lowercased()
            )

        case .login:
            let mobile = context.authUserData?.phone.isEmpty == false
                ? context.authUserData?.phone
                : context.recipient

            guard let mobile, mobile.isValidPhoneNumber() else {
                LoaderManager.shared.hide()
                showToastSafely("Please enter a valid 10-digit mobile number")
                return
            }

            request = SendOTPRequest(
                name: nil,
                email: nil,
                mobile: mobile,
                userType: context.userRole.rawValue.lowercased()
            )
        }

        viewModel.sendOTP(request: request) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Failed to send OTP")
                    return
                }

                self.expectedOTP = response.otp.map(String.init)
                if isResend {
                    self.showToastSafely(response.msg ?? "OTP resent successfully")
                }

            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func persistVerifiedSessionIfNeeded(_ data: VerifyOTPUserData?, for context: OTPFlowContext) {
        guard context.destination == .home || context.destination == .completeProfile else { return }

        let nameParts = (data?.name ?? "").split(separator: " ").map(String.init)
        let firstName = nameParts.first
        let lastName = nameParts.dropFirst().joined(separator: " ")

        let user = LoginUser(
            userID: data?.resolvedUserID,
            emailID: data?.email,
            isBlocked: nil,
            isVerified: nil,
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            state: nil,
            city: nil,
            countryCode: nil,
            phoneNumber: data?.mobile,
            address: nil,
            latitude: nil,
            longitude: nil,
            imageURL: data?.image,
            roleID: data?.role ?? data?.userType
        )

        UserCache.shared.saveUserDataWhenLogin(model: user, token: data?.accessToken)
        UserCache.shared.saveScopedUserIDs(
            studentId: data?.studentId,
            teacherId: data?.teacherId,
            instituteId: data?.instituteId
        )
        UserDefaults.standard.set(true, forKey: LoginKeys.isLoggedIn)
        AppDefaultsService.refreshIfAuthenticated()
    }

    func errorMessage(from error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternetConnection:
                return "No internet connection. Please try again."
            case .apiError(let message):
                return message
            case .requestFailed(let message):
                return message
            case .validation(let apiError):
                return apiError.error.first?.message ?? "Validation failed. Please check your input."
            case .invalidURL:
                return "Invalid request URL."
            case .decodingError(let message):
                return message
            }
        }
        return error.localizedDescription
    }
}

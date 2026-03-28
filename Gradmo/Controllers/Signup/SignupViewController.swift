//
//  SignupViewController.swift
//  Gradmo
//
//  Created by Philanderer on 15/03/26.
//

import UIKit

final class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var gradmoHeadingLabel: UILabel!
    @IBOutlet private weak var userTypeLabel: UILabel!
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var userFullName: UITextField!
    @IBOutlet private weak var userPhoneNumber: UITextField!
    @IBOutlet private weak var userEmail: UITextField!
    @IBOutlet private weak var userPassword: UITextField!
    @IBOutlet private weak var signinButton: UIButton!
    @IBOutlet private weak var getOtpButton: UIButton!

    var selectedRole: UserRole = .student

    private var authUserData = AuthUserData()
    private var selectedOTPChannel: OTPDeliveryChannel = .phone
    private let signupViewModel = SignupViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [userFullName, userEmail, userPhoneNumber, userPassword, getOtpButton, signinButton].forEach {
            $0?.applyCapsuleCornerRadius()
        }
    }
}

// MARK: - Setup

private extension SignupViewController {

    func setupUI() {
        hideKeyboardWhenTappedAround()

        authUserData.userRole = selectedRole

        gradmoHeadingLabel.text = "Join Gradmo"
        userTypeLabel.text = "As a \(selectedRole.titleText)"

        gradmoHeadingLabel.font = UIFont.GilroyBold(ofSize: 36)
        userTypeLabel.font = UIFont.GilroyMedium(ofSize: 26)
        getOtpButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)
        signinButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)

        userFullName.configureFormField(font: UIFont.GilroyRegular(ofSize: 12), leftPadding: 10)
        userEmail.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 12),
            leftPadding: 10,
            keyboardType: .emailAddress,
            delegate: self
        )
        userPhoneNumber.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 12),
            leftPadding: 10,
            keyboardType: .phonePad,
            delegate: self
        )
        userPassword.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 12),
            leftPadding: 10,
            delegate: self,
            isSecureEntry: true
        )

        [userFullName, userEmail, userPhoneNumber, userPassword].forEach {
            $0?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }

        getOtpButton.setEnabledStyle(false)
    }

    func updateButtonState() {
        let fullName = userFullName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = userEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = userPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = userPassword.text ?? ""

        authUserData.fullName = fullName
        authUserData.email = email
        authUserData.phone = phone
        authUserData.password = password
        authUserData.userRole = selectedRole

        let isEnabled = !fullName.isEmpty &&
            email.isValidEmail() &&
            isValidSignupPhone(phone) &&
            password.isValidPassword()

        getOtpButton.setEnabledStyle(isEnabled)
    }

    func makeOTPContextForSignup() -> OTPFlowContext {
        let recipient = selectedOTPChannel == .phone ? authUserData.phone : authUserData.email

        return OTPFlowContext(
            purpose: .signup,
            channel: selectedOTPChannel,
            destination: .completeProfile,
            recipient: recipient,
            userRole: selectedRole,
            authUserData: authUserData
        )
    }

    func navigateToOTP(with context: OTPFlowContext) {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "OTPViewController"
        ) as! OTPViewController
        viewController.context = context
        viewController.initialExpectedOTP = nil
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Actions

extension SignupViewController {

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func editProfileImageButtonTapped(_ sender: UIButton) {
    }

    @IBAction func getOtpButtonTapped(_ sender: UIButton) {
        guard !authUserData.fullName.isEmpty else {
            showToastSafely("Please enter your full name")
            return
        }

        guard authUserData.email.isValidEmail() else {
            showToastSafely("Please enter a valid email address")
            return
        }

        guard isValidSignupPhone(authUserData.phone) else {
            showToastSafely("Please enter a valid 10-digit phone number")
            return
        }

        guard authUserData.password.isValidPassword() else {
            showToastSafely("Password must be at least 8 characters and include uppercase, lowercase, number, and special character")
            return
        }

        submitSignupAndProceed()
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "LogInViewController"
        ) as! LogInViewController
        viewController.selectedRole = selectedRole
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Input Handling

extension SignupViewController {

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateButtonState()
    }

    private func isValidSignupPhone(_ phone: String) -> Bool {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed)
    }

    private func submitSignupAndProceed() {
        view.endEditing(true)
        getOtpButton.setEnabledStyle(false)
        LoaderManager.shared.show()

        let request = SignupUpsertRequest(
            userType: selectedRole.rawValue.lowercased(),
            name: authUserData.fullName,
            email: authUserData.email,
            mobile: authUserData.phone,
            password: authUserData.password,
            deviceId: "",
            deviceToken: "",
            deviceType: "android"
        )

        signupViewModel.submitUserProfile(request: request) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()
            self.updateButtonState()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Unable to continue signup")
                    return
                }

                guard response.otp != nil else {
                    self.showToastSafely(response.msg ?? "Unable to continue signup")
                    return
                }

                if let data = response.data {
                    self.authUserData.studentId = data.studentId ?? ""
                    self.authUserData.teacherId = data.teacherId ?? ""
                    self.authUserData.instituteId = data.instituteId ?? ""
                    self.authUserData.imageURL = data.image ?? ""
                }

                UserCache.saveSelectedUserRole(self.selectedRole)
                let context = self.makeOTPContextForSignup()
                let viewController = self.storyboard?.instantiateViewController(
                    withIdentifier: "OTPViewController"
                ) as! OTPViewController
                viewController.context = context
                viewController.initialExpectedOTP = response.otp.map(String.init)
                self.navigationController?.pushViewController(viewController, animated: true)

            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    private func errorMessage(from error: Error) -> String {
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

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == userPhoneNumber else {
            return true
        }

        if string.isEmpty {
            return true
        }

        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }

        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        if newLength > 10 {
            showToastSafely("Phone number cannot exceed 10 digits")
            return false
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userEmail {
            let email = (userEmail.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !email.isEmpty, !email.isValidEmail() {
                view.showNativeToast("Please enter a valid email address")
            }
            return
        }

        if textField == userPassword {
            let password = userPassword.text ?? ""
            if let message = passwordValidationMessage(for: password) {
                view.showNativeToast(message)
            }
        }
    }

    private func passwordValidationMessage(for password: String) -> String? {
        if password.isEmpty {
            return "Please enter password"
        }
        if password.count < 8 {
            return "Password must be at least 8 characters"
        }
        if !password.contains(where: \.isUppercase) {
            return "Password must include at least 1 uppercase letter"
        }
        if !password.contains(where: \.isNumber) {
            return "Password must include at least 1 number"
        }

        let specialCharacterSet = CharacterSet(charactersIn: "!@#$&*")
        if password.rangeOfCharacter(from: specialCharacterSet) == nil {
            return "Password must include at least 1 special character: ! @ # $ & *"
        }

        return nil
    }
}

//
//  LogInViewController.swift
//  Gradmo
//
//  Created by Philanderer on 15/03/26.
//

import UIKit

private enum LoginMethod {
    case phone
    case email
}

final class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var gradmoHeadingLabel: UILabel!
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var userPhoneNumber: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var getOtpButton: UIButton!
    @IBOutlet private weak var eyeButton: UIButton!

    var selectedRole: UserRole = .student
    var shouldHideCancelButton: Bool = false

    private var authUserData = AuthUserData()
    private var loginMethod: LoginMethod = .phone
    private let viewModel = LogInViewModel()
    private let otpViewModel = OTPViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [userPhoneNumber, passwordTextfield, getOtpButton, signUpButton].forEach {
            $0?.applyCapsuleCornerRadius()
        }
    }
}

// MARK: - Setup

private extension LogInViewController {

    func setupUI() {
        hideKeyboardWhenTappedAround()

        authUserData.userRole = selectedRole

        gradmoHeadingLabel.text = "Welcome Back"
        gradmoHeadingLabel.font = UIFont.GilroyBold(ofSize: 26)
        userPhoneNumber.font = UIFont.GilroyRegular(ofSize: 12)
        passwordTextfield.font = UIFont.GilroyRegular(ofSize: 12)
        getOtpButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)
        signUpButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)
        forgotPasswordButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)
        cancelButton.isHidden = shouldHideCancelButton
        cancelButton.isUserInteractionEnabled = !shouldHideCancelButton

        userPhoneNumber.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 12),
            leftPadding: 10,
            delegate: self
        )
        passwordTextfield.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 12),
            leftPadding: 10,
            rightPadding: 50,
            delegate: self,
            isSecureEntry: true
        )

        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .systemGray

        userPhoneNumber.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)

        applyPhoneMode(animated: false)
        updateActionButton()
    }

    func detectedMethod(for text: String) -> LoginMethod {
        let hasLetter = text.contains { $0.isLetter }
        let hasAtSign = text.contains("@")
        return (hasLetter || hasAtSign) ? .email : .phone
    }

    func applyPhoneMode(animated: Bool) {
        loginMethod = .phone
        userPhoneNumber.placeholder = "Enter phone number"
        userPhoneNumber.keyboardType = .numberPad
        userPhoneNumber.reloadInputViews()
        getOtpButton.setTitle("Get OTP", for: .normal)

        setPasswordSection(visible: false, animated: animated)
    }

    func applyEmailMode(animated: Bool) {
        loginMethod = .email
        userPhoneNumber.placeholder = "Enter email address"
        userPhoneNumber.keyboardType = .emailAddress
        userPhoneNumber.reloadInputViews()
        getOtpButton.setTitle("Sign In", for: .normal)

        setPasswordSection(visible: true, animated: animated)
    }

    func setPasswordSection(visible: Bool, animated: Bool) {
        let alpha: CGFloat = visible ? 1.0 : 0.0
        let animations = {
            self.passwordTextfield.alpha = alpha
            self.eyeButton.alpha = alpha
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: animations)
        } else {
            animations()
        }

        passwordTextfield.isUserInteractionEnabled = visible
        eyeButton.isUserInteractionEnabled = visible
    }

    func updateActionButton() {
        let isEnabled: Bool

        switch loginMethod {
        case .phone:
            isEnabled = (userPhoneNumber.text ?? "").isValidPhoneNumber()
        case .email:
            let email = userPhoneNumber.text ?? ""
            let password = passwordTextfield.text ?? ""
            isEnabled = email.isValidEmail() && !password.isEmpty
        }

        getOtpButton.setEnabledStyle(isEnabled)
    }

    func makeOTPContextForLogin() -> OTPFlowContext {
        authUserData.userRole = selectedRole
        authUserData.phone = userPhoneNumber.text ?? ""

        return OTPFlowContext(
            purpose: .login,
            channel: .phone,
            destination: .home,
            recipient: authUserData.phone,
            userRole: selectedRole,
            authUserData: authUserData
        )
    }

    func navigateToOTP(with context: OTPFlowContext, otp: Int? = nil, toastMessage: String? = nil) {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "OTPViewController"
        ) as! OTPViewController
        viewController.context = context
        viewController.initialExpectedOTP = otp.map(String.init)
        viewController.initialToastMessage = toastMessage
        navigationController?.pushViewController(viewController, animated: true)
    }

    func navigateToHome() {
        UserCache.saveSelectedUserRole(selectedRole)
        CommonClass.shared.moveToHome()
    }
}

// MARK: - Actions

extension LogInViewController {

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func getOtpButtonTapped(_ sender: UIButton) {
        switch loginMethod {
        case .phone:
            handlePhoneLogin()
        case .email:
            handleEmailLogin()
        }
    }

    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        passwordTextfield.togglePasswordVisibility(using: eyeButton)
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "SignupViewController"
        ) as! SignupViewController
        viewController.selectedRole = selectedRole
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "ForgotPasswordViewController"
        ) as! ForgotPasswordViewController
        viewController.selectedRole = selectedRole
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Input Handling

extension LogInViewController {

    @objc private func inputDidChange() {
        let input = userPhoneNumber.text ?? ""
        let detected = detectedMethod(for: input)

        if detected != loginMethod {
            detected == .phone ? applyPhoneMode(animated: true) : applyEmailMode(animated: true)
        }

        updateActionButton()
    }

    private func handlePhoneLogin() {
        guard let phone = userPhoneNumber.text, phone.isValidPhoneNumber() else {
            showToastSafely("Please enter a valid 10-digit phone number")
            return
        }

        view.endEditing(true)
        getOtpButton.setEnabledStyle(false)
        LoaderManager.shared.show()
        authUserData.phone = phone

        let request = SendOTPRequest(
            name: nil,
            email: nil,
            mobile: phone,
            userType: selectedRole.rawValue.lowercased()
        )

        otpViewModel.sendOTP(request: request) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()
            self.updateActionButton()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Unable to send OTP")
                    return
                }

                self.navigateToOTP(
                    with: self.makeOTPContextForLogin(),
                    otp: response.otp,
                    toastMessage: response.msg ?? "OTP sent successfully"
                )

            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    private func handleEmailLogin() {
        guard let email = userPhoneNumber.text, email.isValidEmail() else {
            showToastSafely("Please enter a valid email address")
            return
        }

        guard let password = passwordTextfield.text, !password.isEmpty else {
            showToastSafely("Please enter your password")
            return
        }

        authUserData.email = email
        authUserData.password = password

        loginWithEmail(email: email, password: password)
    }

    private func loginWithEmail(email: String, password: String) {
        view.endEditing(true)
        getOtpButton.setEnabledStyle(false)
        LoaderManager.shared.show()

        viewModel.loginUser(
            username: email,
            password: password,
            userType: selectedRole.rawValue.lowercased()
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                LoaderManager.shared.hide()
                self.updateActionButton()
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Login failed")
                    return
                }

                self.viewModel.persistLoginSession(response.data, fallbackRole: self.selectedRole)
                self.navigateToHome()

            case .failure(let error):
                LoaderManager.shared.hide()
                self.updateActionButton()
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
}

// MARK: - UITextFieldDelegate

extension LogInViewController {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == userPhoneNumber, loginMethod == .phone else {
            return true
        }

        if string.isEmpty {
            return true
        }

        let isDigitsOnly = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        if !isDigitsOnly {
            return true
        }

        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        if newLength > 10 {
            showToastSafely("Phone number cannot exceed 10 digits")
            return false
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userPhoneNumber, loginMethod == .email {
            passwordTextfield.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

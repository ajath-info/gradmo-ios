//
//  ResetPasswordViewController.swift
//  Gradmo
//
//  Created by Philanderer on 21/03/26.
//

import UIKit
import Alamofire

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets

    @IBOutlet weak var gradmoHeadingLabel: UILabel!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    @IBOutlet weak var confirmNewPasswordTextfield: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    // MARK: - Properties

    var mobile: String?
    var selectedRole: UserRole = .student
    private var lastValidationToastMessage: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        applyCornerRadius()
    }

    // MARK: - Actions

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        handleSubmit()
    }
}

// MARK: - UI Setup

extension ResetPasswordViewController {

    private func setupUI() {
        hideKeyboardWhenTappedAround()

        // Text
        gradmoHeadingLabel.text = "Reset Password"

        // Fonts
        gradmoHeadingLabel.font = UIFont.GilroyBold(ofSize: 36)
        newPasswordTextfield.font = UIFont.GilroyRegular(ofSize: 14)
        confirmNewPasswordTextfield.font = UIFont.GilroyRegular(ofSize: 14)
        submitButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)

        newPasswordTextfield.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 14),
            delegate: self,
            isSecureEntry: true
        )
        confirmNewPasswordTextfield.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 14),
            delegate: self,
            isSecureEntry: true
        )

        // Targets
        newPasswordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        confirmNewPasswordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        updateSubmitButton()
    }

    private func applyCornerRadius() {
        [newPasswordTextfield, confirmNewPasswordTextfield, submitButton].forEach {
            $0?.applyCapsuleCornerRadius()
        }
    }
}

// MARK: - Validation

extension ResetPasswordViewController {

    @objc private func textDidChange() {
        updateSubmitButton()
        showLiveValidationFeedbackIfNeeded()
    }

    private func updateSubmitButton() {
        let password = newPasswordTextfield.text ?? ""
        let confirmPassword = confirmNewPasswordTextfield.text ?? ""

        let isValid = password.isValidPassword() && (password == confirmPassword)

        submitButton.setEnabledStyle(isValid)
    }

    private func passwordValidationMessage(for password: String) -> String? {
        guard !password.isEmpty else {
            return nil
        }

        if password.count < 8 {
            return "Password must be at least 8 characters"
        }

        if !password.contains(where: \.isUppercase) {
            return "Password must include at least 1 uppercase letter"
        }

        if !password.contains(where: \.isLowercase) {
            return "Password must include at least 1 lowercase letter"
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

    private func showLiveValidationFeedbackIfNeeded() {
        let password = newPasswordTextfield.text ?? ""
        let confirmPassword = confirmNewPasswordTextfield.text ?? ""

        let validationMessage: String?
        if let passwordMessage = passwordValidationMessage(for: password) {
            validationMessage = passwordMessage
        } else if !confirmPassword.isEmpty, password != confirmPassword {
            validationMessage = "Passwords do not match"
        } else {
            validationMessage = nil
        }

        guard validationMessage != lastValidationToastMessage else {
            return
        }

        lastValidationToastMessage = validationMessage

        if let validationMessage {
            view.showNativeToast(validationMessage)
        }
    }
}

// MARK: - Submit Logic

extension ResetPasswordViewController {

    private func handleSubmit() {
        guard let mobile = mobile?.trimmingCharacters(in: .whitespacesAndNewlines),
              mobile.isValidPhoneNumber() else {
            showToastSafely("Mobile number is missing")
            return
        }

        guard let password = newPasswordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let confirmPassword = confirmNewPasswordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }

        guard password.isValidPassword() else {
            showToastSafely("Password must be at least 8 characters and include uppercase, lowercase, number, and special character")
            return
        }

        guard password == confirmPassword else {
            showToastSafely("Passwords do not match")
            return
        }

        resetPassword(mobile: mobile, password: password, confirmPassword: confirmPassword)
    }

    private func navigateToLogin() {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "LogInViewController"
        ) as! LogInViewController
        viewController.selectedRole = selectedRole
        viewController.shouldHideCancelButton = true
        navigationController?.setViewControllers([viewController], animated: true)
    }

    private func resetPassword(mobile: String, password: String, confirmPassword: String) {
        view.endEditing(true)
        submitButton.setEnabledStyle(false)
        LoaderManager.shared.show()

        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        let parameters: [String: Any] = [
            APIKeys.mobile: mobile,
            APIKeys.password: password,
            APIKeys.confirmPassword: confirmPassword,
            APIKeys.userType: selectedRole.rawValue.lowercased()
        ]
        let url = Constant.baseUrl + API.updatePasswordAPI

        Task {
            do {
                let response: UpdatePasswordResponse = try await APIManager.shared.post(
                    url,
                    parameters: parameters,
                    headers: headers,
                    expectsWrappedResponse: false
                )

                await MainActor.run {
                    LoaderManager.shared.hide()
                    self.updateSubmitButton()

                    guard response.isSuccess else {
                        self.showToastSafely(response.msg ?? "Unable to update password")
                        return
                    }

                    self.showToastSafely(response.msg ?? "Password updated successfully")
                    self.navigateToLogin()
                }
            } catch {
                await MainActor.run {
                    LoaderManager.shared.hide()
                    self.updateSubmitButton()
                    self.showToastSafely(self.errorMessage(from: error))
                }
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

extension ResetPasswordViewController {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPasswordTextfield {
            confirmNewPasswordTextfield.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

private struct UpdatePasswordResponse: Decodable {
    let status: String
    let msg: String?

    var isSuccess: Bool {
        status.lowercased() == "true"
    }
}

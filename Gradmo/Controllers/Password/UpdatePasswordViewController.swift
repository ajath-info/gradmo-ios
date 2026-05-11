//
//  UpdatePasswordViewController.swift
//  Gradmo
//
//  Created by Philanderer on 28/03/26.
//

import UIKit
import Alamofire

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var gradmoHeadingLabel: UILabel!
    @IBOutlet weak var yourPasswordTextfield: UITextField!
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
extension UpdatePasswordViewController {

    private func setupUI() {
        hideKeyboardWhenTappedAround()

        // Text
        gradmoHeadingLabel.text = "Update Password"

        // Fonts
        gradmoHeadingLabel.font = UIFont.GilroyBold(ofSize: 36)
        yourPasswordTextfield.font = UIFont.GilroyRegular(ofSize: 14)
        newPasswordTextfield.font = UIFont.GilroyRegular(ofSize: 14)
        confirmNewPasswordTextfield.font = UIFont.GilroyRegular(ofSize: 14)
        submitButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)

        yourPasswordTextfield.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 14),
            delegate: self,
            isSecureEntry: true
        )
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
        yourPasswordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        newPasswordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        confirmNewPasswordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        updateSubmitButton()
    }

    private func applyCornerRadius() {
        [yourPasswordTextfield, newPasswordTextfield, confirmNewPasswordTextfield, submitButton].forEach {
            $0?.applyCapsuleCornerRadius()
        }
    }
}

// MARK: - Validation
extension UpdatePasswordViewController {

    @objc private func textDidChange() {
        updateSubmitButton()
        showLiveValidationFeedbackIfNeeded()
    }

    private func updateSubmitButton() {
        let currentPassword = yourPasswordTextfield.text ?? ""
        let password = newPasswordTextfield.text ?? ""
        let confirmPassword = confirmNewPasswordTextfield.text ?? ""

        let isValid = !currentPassword.isEmpty &&
            password.isValidPassword() &&
            password == confirmPassword &&
            password != currentPassword

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
        let currentPassword = yourPasswordTextfield.text ?? ""
        let password = newPasswordTextfield.text ?? ""
        let confirmPassword = confirmNewPasswordTextfield.text ?? ""

        let validationMessage: String?
        if currentPassword.isEmpty {
            validationMessage = nil
        } else if let passwordMessage = passwordValidationMessage(for: password) {
            validationMessage = passwordMessage
        } else if !password.isEmpty, password == currentPassword {
            validationMessage = "New password must be different from current password"
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
extension UpdatePasswordViewController {

    private func handleSubmit() {
        guard let currentPassword = yourPasswordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !currentPassword.isEmpty else {
            showToastSafely("Please enter your current password")
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

        guard password != currentPassword else {
            showToastSafely("New password must be different from current password")
            return
        }

        view.endEditing(true)
        changePassword(currentPassword: currentPassword, newPassword: password, confirmPassword: confirmPassword)
    }

    private func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) {
        submitButton.setEnabledStyle(false)
        LoaderManager.shared.show()

        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        let parameters: [String: Any] = [
            APIKeys.currentPassword: currentPassword,
            APIKeys.newPassword: newPassword,
            APIKeys.confirmPassword: confirmPassword
        ]
        let url = Constant.baseUrl + API.changePasswordAPI

        Task {
            do {
                let response: ChangePasswordResponse = try await APIManager.shared.post(
                    url,
                    parameters: parameters,
                    headers: headers,
                    expectsWrappedResponse: false
                )

                await MainActor.run {
                    LoaderManager.shared.hide()
                    self.updateSubmitButton()

                    guard response.isSuccess else {
                        let message = response.msg ?? "Unable to change password"
                        self.showToastSafely(message)

                        if response.requiresRelogin {
                            self.handleAuthenticationFailure()
                        }
                        return
                    }

                    self.showToastSafely(response.msg ?? "Password changed successfully")
                    self.clearForm()
                    self.updateSubmitButton()
                    self.navigationController?.popViewController(animated: true)
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

    private func clearForm() {
        yourPasswordTextfield.text = ""
        newPasswordTextfield.text = ""
        confirmNewPasswordTextfield.text = ""
        lastValidationToastMessage = nil
    }

    private func handleAuthenticationFailure() {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "LogInViewController"
        ) as! LogInViewController
        viewController.selectedRole = selectedRole
        viewController.shouldHideCancelButton = true
        navigationController?.setViewControllers([viewController], animated: true)
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
extension UpdatePasswordViewController {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == yourPasswordTextfield {
            newPasswordTextfield.becomeFirstResponder()
        } else if textField == newPasswordTextfield {
            confirmNewPasswordTextfield.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

private struct ChangePasswordResponse: Decodable {
    let status: String
    let msg: String?
    let code: String?

    var isSuccess: Bool {
        status.lowercased() == "true"
    }

    var requiresRelogin: Bool {
        code == nil && msg?.localizedCaseInsensitiveContains("log in again") == true
    }
}

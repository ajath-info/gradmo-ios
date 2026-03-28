//
//  UpdatePasswordViewController.swift
//  Gradmo
//
//  Created by Philanderer on 28/03/26.
//

import UIKit

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
        showToastSafely("Password details are valid. API integration is pending.")
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

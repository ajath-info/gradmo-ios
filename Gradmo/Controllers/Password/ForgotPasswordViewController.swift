//
//  ForgotPasswordViewController.swift
//  Gradmo
//
//  Created by Philanderer on 21/03/26.
//

import UIKit

final class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var gradmoHeadingLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!

    var selectedRole: UserRole = .student
    private let viewModel = OTPViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [emailTextField, submitButton].forEach {
            $0?.applyCapsuleCornerRadius()
        }
    }
}

// MARK: - Setup

private extension ForgotPasswordViewController {

    func setupUI() {
        hideKeyboardWhenTappedAround()

        gradmoHeadingLabel.text = "Forgot Password"
        gradmoHeadingLabel.font = UIFont.GilroyBold(ofSize: 36)
        submitButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)

        emailTextField.configureFormField(
            font: UIFont.GilroyRegular(ofSize: 14),
            keyboardType: .numberPad,
            delegate: self
        )

        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        updateSubmitButton()
    }

    func updateSubmitButton() {
        submitButton.setEnabledStyle((emailTextField.text ?? "").isValidPhoneNumber())
    }

    func makeOTPContext() -> OTPFlowContext {
        let mobile = emailTextField.text ?? ""
        return OTPFlowContext(
            purpose: .forgotPassword,
            channel: .phone,
            destination: .resetPassword,
            recipient: mobile,
            userRole: selectedRole,
            authUserData: AuthUserData(phone: mobile, userRole: selectedRole)
        )
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

    func navigateToOTP(with context: OTPFlowContext, otp: Int?, toastMessage: String? = nil) {
        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "OTPViewController"
        ) as! OTPViewController
        viewController.context = context
        viewController.initialExpectedOTP = otp.map(String.init)
        viewController.initialToastMessage = toastMessage
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Actions
extension ForgotPasswordViewController {

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let mobile = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              mobile.isValidPhoneNumber() else {
            showToastSafely("Please enter a valid 10-digit mobile number")
            return
        }

        view.endEditing(true)
        submitButton.setEnabledStyle(false)
        LoaderManager.shared.show()

        let request = SendOTPRequest(
            name: nil,
            email: nil,
            mobile: mobile,
            userType: selectedRole.rawValue.lowercased()
        )

        viewModel.sendOTP(request: request) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()
            self.updateSubmitButton()

            switch result {
            case .success(let response):
                guard response.status else {
                    self.showToastSafely(response.msg ?? "Unable to send OTP")
                    return
                }

                self.navigateToOTP(
                    with: self.makeOTPContext(),
                    otp: response.otp,
                    toastMessage: response.msg ?? "OTP sent successfully"
                )

            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }
}

// MARK: - Input Handling

extension ForgotPasswordViewController {

    @objc private func textDidChange() {
        updateSubmitButton()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == emailTextField else { return true }
        guard string.isEmpty || string.allSatisfy(\.isNumber) else { return false }

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return updatedText.count <= 10
    }
}

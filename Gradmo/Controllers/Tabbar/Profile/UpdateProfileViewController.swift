//
//  UpdateProfileViewController.swift
//  Gradmo
//
//  Created by Philanderer on 28/03/26.
//

import UIKit
import SDWebImage

class UpdateProfileViewController: UIViewController {

    @IBOutlet private weak var completeProfileHeadingLabel: UILabel!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet private weak var personalInformationHeadingLabel: UILabel!
    @IBOutlet private weak var educationalInformationHeadingLabel: UILabel!
    @IBOutlet private weak var userNameHeadingLabel: UILabel!
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var userFullName: UITextField!
    @IBOutlet private weak var userPhoneNumber: UITextField!
    @IBOutlet private weak var userEmail: UITextField!
    @IBOutlet private weak var houseDetail: UITextField!
    @IBOutlet private weak var country: UITextField!
    @IBOutlet private weak var state: UITextField!
    @IBOutlet private weak var pincode: UITextField!
    @IBOutlet private weak var schoolName: UITextField!
    @IBOutlet private weak var grade: UITextField!
    @IBOutlet private weak var saveButton: UIButton!

    let countries = ["India", "USA", "UK", "Canada", "Australia"]
    let statesIndia = [
        "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
        "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand",
        "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur",
        "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
        "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura",
        "Uttar Pradesh", "Uttarakhand", "West Bengal"
    ]

    var selectedRole: UserRole = .student
    var authUserData: AuthUserData?
    var isEditingFromSideMenu = false
    private let viewModel = CompleteProfileViewModel()
    private var selectedProfileImageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedRole = authUserData?.userRole ?? UserCache.getUserRole()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = isEditingFromSideMenu
        configureScreenMode()
        populateInitialValues()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isEditingFromSideMenu {
            tabBarController?.tabBar.isHidden = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [profileImage, saveButton, userFullName, userEmail, userPhoneNumber, houseDetail, country, state, pincode, schoolName, grade].forEach {
            $0?.applyCapsuleCornerRadius()
        }
    }
}

// MARK: - Setup

private extension UpdateProfileViewController {

    func setupUI() {
        hideKeyboardWhenTappedAround()

        completeProfileHeadingLabel.text = "\(selectedRole.titleText) Profile"
        completeProfileHeadingLabel.font = UIFont.GilroyBold(ofSize: 21)
        personalInformationHeadingLabel.font = UIFont.GilroyBold(ofSize: 21)
        educationalInformationHeadingLabel.font = UIFont.GilroyBold(ofSize: 21)
        userNameHeadingLabel.font = UIFont.GilroyBold(ofSize: 21)
        saveButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)

        country.isUserInteractionEnabled = false
        state.isUserInteractionEnabled = false
        userPhoneNumber.keyboardType = .numberPad
        pincode.keyboardType = .numberPad
        userEmail.keyboardType = .emailAddress

        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.lightGray.cgColor

        setupTextFields()
        configureScreenMode()
    }

    func printSavedUserDefaults() {
        let savedValues: [String: String] = [
            "fullName": UserCache.fullName(),
            "email": UserCache.email_id(),
            "phone": UserCache.phone(),
            "address": UserCache.address(),
            "country": UserCache.country(),
            "state": UserCache.state(),
            "city": UserCache.city(),
            "pincode": UserCache.pincode(),
            "schoolCollegeName": UserCache.schoolCollegeName(),
            "grade": UserCache.grade(),
            "profileImageURL": UserCache.profileImageURL(),
            "userID": UserCache.userID(),
            "token": UserCache.token(),
            "role": UserCache.getUserRole().rawValue
        ]

        print("========== UpdateProfile UserDefaults ==========")
        savedValues.forEach { key, value in
            print("\(key): \(value)")
        }
        print("===============================================")
    }

    func setupTextFields() {
        let fields = [
            userFullName,
            userEmail,
            userPhoneNumber,
            houseDetail,
            country,
            state,
            pincode,
            schoolName,
            grade
        ]

        fields.forEach {
            $0?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            $0?.setLeftPaddingPoints(12)
            $0?.delegate = self
            $0?.font = UIFont.GilroyMedium(ofSize: 12)
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }

    func populateInitialValues() {
        let fallbackData = authUserData ?? AuthUserData(
            fullName: UserCache.fullName(),
            email: UserCache.email_id(),
            phone: UserCache.phone(),
            studentId: selectedRole == .student ? UserCache.userID() : "",
            teacherId: selectedRole == .teacher ? UserCache.userID() : "",
            instituteId: selectedRole == .institute ? UserCache.userID() : "",
            imageURL: UserCache.profileImageURL(),
            accessToken: UserCache.token(),
            userRole: selectedRole
        )

        if authUserData == nil {
            authUserData = fallbackData
        }

        userNameHeadingLabel.text = fallbackData.fullName
        userFullName.text = fallbackData.fullName
        userEmail.text = fallbackData.email
        userPhoneNumber.text = fallbackData.phone
        houseDetail.text = UserCache.address()
        country.text = UserCache.country().isEmpty ? "India" : UserCache.country()
        state.text = UserCache.state()
        pincode.text = UserCache.pincode()
        schoolName.text = UserCache.schoolCollegeName()
        grade.text = UserCache.grade()

        if let imageURL = URL(string: fallbackData.imageURL), !fallbackData.imageURL.isEmpty {
            profileImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "profilePic"))
        } else {
            profileImage.image = UIImage(named: "profilePic")
        }

        textFieldDidChange()
    }

    func enableSaveButton(_ enable: Bool) {
        saveButton.setEnabledStyle(enable)
    }

    func configureScreenMode() {
        let isEditable = isEditingFromSideMenu

        crossButton.isHidden = !isEditable
        saveButton.isHidden = !isEditable
        editButton.isHidden = !isEditable

        [
            userFullName,
            userPhoneNumber,
            userEmail,
            houseDetail,
            pincode,
            schoolName,
            grade
        ].forEach { $0?.isUserInteractionEnabled = isEditable }

        country.isUserInteractionEnabled = false
        state.isUserInteractionEnabled = false
        profileImage.isUserInteractionEnabled = isEditable

        if isEditable {
            textFieldDidChange()
        } else {
            enableSaveButton(false)
        }
    }
}

// MARK: - Actions

extension UpdateProfileViewController {

    @IBAction func countryDropdownButtonTapped(_ sender: UIButton) {
        guard isEditingFromSideMenu else { return }
        let alert = UIAlertController(title: "Select Country",
                                      message: nil,
                                      preferredStyle: .actionSheet)

        for countryName in countries {
            alert.addAction(UIAlertAction(title: countryName, style: .default) { _ in
                self.country.text = countryName
                self.state.text = ""
                self.textFieldDidChange()
            })
        }

        present(alert, animated: true)
    }

    @IBAction func stateDropdownButtonTapped(_ sender: UIButton) {
        guard isEditingFromSideMenu else { return }
        let viewController = StatePickerViewController()
        viewController.states = statesIndia
        viewController.onStateSelected = { state in
            self.state.text = state
            self.textFieldDidChange()
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        submitProfile()
    }

    @IBAction func editProfileImageButtonTapped(_ sender: UIButton) {
        guard isEditingFromSideMenu else { return }
        openImagePicker()
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Validation

extension UpdateProfileViewController {

    @objc func textFieldDidChange() {
        guard isEditingFromSideMenu else { return }

        let name = userFullName.text ?? ""
        let email = userEmail.text ?? ""
        let phone = userPhoneNumber.text ?? ""

        let isValid = !name.isEmpty &&
            email.isValidEmail() &&
            isValidMobile(phone)

        enableSaveButton(isValid)
    }

    private func isValidMobile(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed)
    }

    private func submitProfile() {
        guard let authUserData else {
            showToastSafely("Signup data is missing")
            return
        }

        let name = (userFullName.text ?? authUserData.fullName).trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (userEmail.text ?? authUserData.email).trimmingCharacters(in: .whitespacesAndNewlines)
        let mobile = (userPhoneNumber.text ?? authUserData.phone).trimmingCharacters(in: .whitespacesAndNewlines)
        let address = (houseDetail.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let countryValue = (country.text ?? "India").trimmingCharacters(in: .whitespacesAndNewlines)
        let stateValue = (state.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cityValue = inferredCity(from: address)
        let pincodeValue = (pincode.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let schoolCollegeName = (schoolName.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let gradeValue = (grade.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let imageURL = selectedProfileImageData == nil ? authUserData.imageURL : ""
        let accessToken = authUserData.accessToken.isEmpty ? UserCache1.authtoken() : authUserData.accessToken

        guard !name.isEmpty, email.isValidEmail(), mobile.isValidPhoneNumber() else {
            showToastSafely("Please fill all required details")
            return
        }

        guard !accessToken.isEmpty else {
            showToastSafely("Session expired. Please sign in again.")
            return
        }

        let request = CompleteProfileUpdateProfileRequest(
            name: name,
            email: email,
            mobile: mobile,
            userType: selectedRole.rawValue.lowercased(),
            address: address,
            country: countryValue,
            state: stateValue,
            city: cityValue,
            imageURL: imageURL,
            pincode: pincodeValue,
            schoolCollegeName: schoolCollegeName,
            grade: gradeValue,
            studentId: authUserData.studentId,
            teacherId: authUserData.teacherId,
            instituteId: authUserData.instituteId,
            isProfileCompleted: "0"
        )

        let fileParts = selectedProfileImageData.map {
            [
                MultipartFilePart(
                    name: APIKeys.image,
                    fileName: "profile.jpg",
                    mimeType: "image/jpeg",
                    data: $0
                )
            ]
        } ?? []

        saveButton.setEnabledStyle(false)
        LoaderManager.shared.show()
        viewModel.updateProfile(request: request, accessToken: accessToken, fileParts: fileParts) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()
            self.textFieldDidChange()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Unable to update profile")
                    return
                }

                let resolvedUserID = response.data?.id ??
                    authUserData.studentId.nonEmpty ??
                    authUserData.teacherId.nonEmpty ??
                    authUserData.instituteId.nonEmpty ??
                    UserCache.userID()
                let resolvedRoleID = response.data?.userType ?? self.selectedRole.rawValue
                let resolvedImageURL = response.data?.image ?? authUserData.imageURL

                UserCache.saveSelectedUserRole(self.selectedRole)
                UserCache.shared.saveEditedProfileData(
                    name: name,
                    email: email,
                    phone: mobile,
                    address: address,
                    country: countryValue,
                    state: stateValue,
                    city: cityValue,
                    pincode: pincodeValue,
                    schoolCollegeName: schoolCollegeName,
                    grade: gradeValue,
                    imageURL: resolvedImageURL,
                    userID: resolvedUserID,
                    roleID: resolvedRoleID,
                    token: accessToken
                )
                UserDefaults.standard.set(true, forKey: LoginKeys.isLoggedIn)
                self.showToastSafely(response.msg ?? "Profile updated successfully")
                self.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: true)

            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func inferredCity(from address: String) -> String {
        _ = address
        return ""
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

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

// MARK: - UITextFieldDelegate

extension UpdateProfileViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == userPhoneNumber {
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return updatedText.count <= 10
        }

        if textField == pincode {
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return updatedText.count <= 6
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userFullName:
            userEmail.becomeFirstResponder()
        case userEmail:
            userPhoneNumber.becomeFirstResponder()
        case userPhoneNumber:
            houseDetail.becomeFirstResponder()
        case houseDetail:
            pincode.becomeFirstResponder()
        case pincode:
            schoolName.becomeFirstResponder()
        case schoolName:
            grade.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }

        return true
    }
}

// MARK: - Image Picker

extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func openImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            profileImage.image = image
            selectedProfileImageData = image.jpegData(compressionQuality: 0.8)
        } else if let image = info[.originalImage] as? UIImage {
            profileImage.image = image
            selectedProfileImageData = image.jpegData(compressionQuality: 0.8)
        }

        dismiss(animated: true)
    }
}

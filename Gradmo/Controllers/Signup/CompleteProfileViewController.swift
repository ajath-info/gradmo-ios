//
//  CompleteProfileViewController.swift
//  Gradmo
//
//  Created by Philanderer on 18/03/26.
//

import UIKit

class CompleteProfileViewController: UIViewController {

    @IBOutlet private weak var lineView: UIView!
    @IBOutlet private weak var completeProfileHeadingLabel: UILabel!
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
    @IBOutlet private weak var city: UITextField!
    @IBOutlet private weak var pincode: UITextField!
    @IBOutlet private weak var schoolName: UITextField!
    @IBOutlet private weak var grade: UITextField!
    @IBOutlet private weak var saveButton: UIButton!

    var selectedRole: UserRole = .student
    var authUserData: AuthUserData?
    private let viewModel = CompleteProfileViewModel()
    private var selectedProfileImageData: Data?
    private var countries: [LocationCountry] = []
    private var states: [LocationState] = []
    private var cities: [LocationCity] = []
    private var selectedCountry: LocationCountry?
    private var selectedState: LocationState?
    private var selectedCity: LocationCity?
    private var hasRepositionedSaveButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateInitialValues()
        fetchCountriesIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [profileImage, saveButton, userFullName, userEmail, userPhoneNumber, houseDetail, country, state, city, pincode, schoolName, grade].forEach {
            $0?.applyCapsuleCornerRadius()
        }
    }
}

// MARK: - Setup

private extension CompleteProfileViewController {

    func setupUI() {
        hideKeyboardWhenTappedAround()

        completeProfileHeadingLabel.text = "\(selectedRole.titleText) Profile"
        completeProfileHeadingLabel.font = UIFont.GilroyBold(ofSize: 21)
        personalInformationHeadingLabel.font = UIFont.GilroyBold(ofSize: 21)
        educationalInformationHeadingLabel.font = UIFont.GilroyBold(ofSize: 21)
        saveButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)

        userPhoneNumber.keyboardType = .numberPad
        pincode.keyboardType = .numberPad
        userEmail.keyboardType = .emailAddress

        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.lightGray.cgColor

        enableSaveButton(false)
        setupTextFields()
        configureFieldsForSelectedRole()
        updateLocationFieldAvailability()
    }

    func setupTextFields() {
        let fields = [
            userFullName,
            userEmail,
            userPhoneNumber,
            houseDetail,
            country,
            state,
            city,
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
        guard let authUserData else {
            return
        }

        userFullName.text = authUserData.fullName
        userEmail.text = authUserData.email
        userPhoneNumber.text = authUserData.phone
        country.text = nil
        state.text = nil
        city.text = nil
        if selectedRole == .institute {
            houseDetail.text = ""
            pincode.text = ""
        }
        resetLocationSelections()
        updateLocationFieldAvailability()
        textFieldDidChange()
    }

    func enableSaveButton(_ enable: Bool) {
        saveButton.setEnabledStyle(enable)
    }

    func configureFieldsForSelectedRole() {
        switch selectedRole {
        case .student:
            lineView.isHidden = false
            educationalInformationHeadingLabel.isHidden = false
            schoolName.isHidden = false
            grade.isHidden = false

            houseDetail.placeholder = "House detail"
            pincode.placeholder = "Pincode"
            houseDetail.keyboardType = .default
            pincode.keyboardType = .numberPad

            [country, state, city].forEach {
                $0?.isHidden = false
            }

        case .teacher:
            lineView.isHidden = true
            educationalInformationHeadingLabel.isHidden = true
            schoolName.isHidden = true
            grade.isHidden = true

            houseDetail.placeholder = "House detail"
            pincode.placeholder = "Pincode"
            houseDetail.keyboardType = .default
            pincode.keyboardType = .numberPad

            [country, state, city].forEach {
                $0?.isHidden = false
            }
            repositionSaveButtonForTeacherIfNeeded()

        case .institute:
            lineView.isHidden = true
            educationalInformationHeadingLabel.isHidden = false
            schoolName.isHidden = true
            grade.isHidden = true

            houseDetail.placeholder = "Number of Students"
            pincode.placeholder = "Number of Teachers"
            houseDetail.keyboardType = .numberPad
            pincode.keyboardType = .numberPad

            [country, state, city].forEach {
                $0?.isHidden = true
            }
        }
    }

    func repositionSaveButtonForTeacherIfNeeded() {
        guard !hasRepositionedSaveButton,
              let containerView = lineView.superview,
              let stackView = saveButton.superview as? UIStackView else {
            return
        }

        stackView.removeArrangedSubview(saveButton)
        saveButton.removeFromSuperview()
        containerView.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: lineView.topAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: saveButton.bottomAnchor, constant: 20)
        ])

        hasRepositionedSaveButton = true
    }

    func fetchCountriesIfNeeded() {
        guard selectedRole != .institute else { return }

        LoaderManager.shared.show()
        viewModel.fetchCountries { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Unable to fetch countries")
                    return
                }
                self.countries = response.countries
            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func fetchStates(country: LocationCountry) {
        LoaderManager.shared.show()
        viewModel.fetchStates(request: StateListRequest(countryId: country.id)) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Unable to fetch states")
                    return
                }
                self.states = response.states
                self.presentStatePicker()
            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func fetchCities(state: LocationState) {
        LoaderManager.shared.show()
        viewModel.fetchCities(request: CityListRequest(stateId: state.id)) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Unable to fetch cities")
                    return
                }
                self.cities = response.cities
                self.presentCityPicker()
            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func resetLocationSelections() {
        selectedCountry = nil
        selectedState = nil
        selectedCity = nil
        countries = []
        states = []
        cities = []
    }

    func resetStateSelection() {
        selectedState = nil
        selectedCity = nil
        states = []
        cities = []
        state.text = nil
        city.text = nil
        updateLocationFieldAvailability()
    }

    func resetCitySelection() {
        selectedCity = nil
        cities = []
        city.text = nil
        updateLocationFieldAvailability()
    }

    func updateLocationFieldAvailability() {
        let canSelectState = selectedCountry != nil
        let canSelectCity = selectedState != nil

        styleSelectionField(state, isEnabled: canSelectState)
        styleSelectionField(city, isEnabled: canSelectCity)
    }

    func styleSelectionField(_ textField: UITextField, isEnabled: Bool) {
        textField.alpha = isEnabled ? 1.0 : 0.6
        textField.textColor = isEnabled ? UIColor.label : UIColor.systemGray
    }

    func presentCountryPicker() {
        guard !countries.isEmpty else {
            showToastSafely("No countries available")
            return
        }

        let viewController = StatePickerViewController()
        viewController.states = countries.map(\.name)
        viewController.searchPlaceholder = "Search Country"
        viewController.screenTitle = "Select Country"
        viewController.onStateSelected = { [weak self] countryName in
            guard let self,
                  let selectedCountry = self.countries.first(where: { $0.name == countryName }) else { return }
            self.selectedCountry = selectedCountry
            self.country.text = selectedCountry.name
            self.resetStateSelection()
            self.fetchStates(country: selectedCountry)
            self.textFieldDidChange()
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    func presentStatePicker() {
        guard !states.isEmpty else {
            showToastSafely("No states available")
            return
        }

        let viewController = StatePickerViewController()
        viewController.states = states.map(\.name)
        viewController.searchPlaceholder = "Search State"
        viewController.screenTitle = "Select State"
        viewController.onStateSelected = { [weak self] stateName in
            guard let self,
                  let selectedState = self.states.first(where: { $0.name == stateName }) else { return }
            self.selectedState = selectedState
            self.state.text = selectedState.name
            self.resetCitySelection()
            self.fetchCities(state: selectedState)
            self.textFieldDidChange()
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    func presentCityPicker() {
        guard !cities.isEmpty else {
            showToastSafely("No cities available")
            return
        }

        let viewController = StatePickerViewController()
        viewController.states = cities.map(\.city)
        viewController.searchPlaceholder = "Search City"
        viewController.screenTitle = "Select City"
        viewController.onStateSelected = { [weak self] cityName in
            guard let self,
                  let selectedCity = self.cities.first(where: { $0.city == cityName }) else { return }
            self.selectedCity = selectedCity
            self.city.text = selectedCity.city
            self.textFieldDidChange()
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

// MARK: - Actions

extension CompleteProfileViewController {

    @IBAction func countryDropdownButtonTapped(_ sender: UIButton) {
        guard selectedRole != .institute else { return }

        if countries.isEmpty {
            fetchCountriesIfNeeded()
            return
        }
        presentCountryPicker()
    }

    @IBAction func stateDropdownButtonTapped(_ sender: UIButton) {
        guard selectedRole != .institute else { return }
        guard let selectedCountry else {
            showToastSafely("Please select country first")
            return
        }

        if states.isEmpty {
            fetchStates(country: selectedCountry)
            return
        }

        presentStatePicker()
    }

    @IBAction func cityDropdownTapped(_ sender: UIButton) {
        guard selectedRole != .institute else { return }
        guard let selectedState else {
            showToastSafely("Please select state first")
            return
        }

        if cities.isEmpty {
            fetchCities(state: selectedState)
            return
        }

        presentCityPicker()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        submitProfile()
    }

    @IBAction func editProfileImageButtonTapped(_ sender: UIButton) {
        openImagePicker()
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Validation

extension CompleteProfileViewController {

    @objc func textFieldDidChange() {
        let name = userFullName.text ?? ""
        let email = userEmail.text ?? ""
        let phone = userPhoneNumber.text ?? ""

        let hasValidLocation = selectedRole == .institute ||
            (selectedCountry != nil && selectedState != nil && selectedCity != nil)

        let isValid = !name.isEmpty &&
            email.isValidEmail() &&
            isValidMobile(phone) &&
            hasValidLocation

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
        let countryValue = selectedRole == .institute
            ? ""
            : (country.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let stateValue = selectedRole == .institute
            ? ""
            : (state.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cityValue = selectedRole == .institute
            ? ""
            : (city.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pincodeValue = (pincode.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let latitudeValue = UserCache.latitude()
        let longitudeValue = UserCache.longitude()
        let schoolCollegeName = selectedRole == .student
            ? (schoolName.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            : ""
        let gradeValue = selectedRole == .student
            ? (grade.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            : ""
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

        if selectedRole != .institute,
           (countryValue.isEmpty || stateValue.isEmpty || cityValue.isEmpty) {
            showToastSafely("Please select country, state and city")
            return
        }

        let request = CompleteProfileUpdateProfileRequest(
            name: name,
            email: email,
            mobile: mobile,
            userType: selectedRole.rawValue.lowercased(),
            address: address,
            latitude: latitudeValue,
            longitude: longitudeValue,
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
                    self.showToastSafely(response.msg ?? "Unable to complete signup")
                    return
                }

                UserCache.saveSelectedUserRole(self.selectedRole)
                UserCache.shared.saveUpdatedProfileData(model: response.data, token: accessToken)
                UserDefaults.standard.set(true, forKey: LoginKeys.isLoggedIn)
                CommonClass.shared.moveToHome()

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
}

// MARK: - UITextFieldDelegate

extension CompleteProfileViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == userPhoneNumber {
            guard string.isEmpty || string.allSatisfy(\.isNumber) else { return false }
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return updatedText.count <= 10
        }

        if textField == pincode {
            guard string.isEmpty || string.allSatisfy(\.isNumber) else { return false }
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let limit = selectedRole == .institute ? 5 : 6
            return updatedText.count <= limit
        }

        if selectedRole == .institute, textField == houseDetail {
            guard string.isEmpty || string.allSatisfy(\.isNumber) else { return false }
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return updatedText.count <= 5
        }

        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == country {
            countryDropdownButtonTapped(UIButton(type: .system))
            return false
        }

        if textField == state {
            stateDropdownButtonTapped(UIButton(type: .system))
            return false
        }

        if textField == city {
            cityDropdownTapped(UIButton(type: .system))
            return false
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
            if selectedRole == .institute {
                pincode.becomeFirstResponder()
            } else {
                pincode.becomeFirstResponder()
            }
        case pincode:
            if selectedRole == .student {
                schoolName.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        case schoolName:
            grade.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }

        return true
    }
}

// MARK: - Image Picker

extension CompleteProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

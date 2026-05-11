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
    @IBOutlet private weak var city: UITextField!
    @IBOutlet private weak var pincode: UITextField!
    @IBOutlet private weak var schoolName: UITextField!
    @IBOutlet private weak var grade: UITextField!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet weak var countryDropdownImage: UIImageView!
    @IBOutlet weak var cityDropdownImage: UIImageView!
    @IBOutlet weak var stateDropdownImage: UIImageView!

    var selectedRole: UserRole = .student
    var authUserData: AuthUserData?
    var isEditingFromSideMenu = false
    private let viewModel = CompleteProfileViewModel()
    private var selectedProfileImageData: Data?
    private var countries: [LocationCountry] = []
    private var states: [LocationState] = []
    private var cities: [LocationCity] = []
    private var selectedCountry: LocationCountry?
    private var selectedState: LocationState?
    private var selectedCity: LocationCity?

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedRole = authUserData?.userRole ?? UserCache.getUserRole()
        setupUI()
        fetchCountriesIfNeeded()
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

        [profileImage, saveButton, userFullName, userEmail, userPhoneNumber, houseDetail, country, state, city, pincode, schoolName, grade].forEach {
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

        userPhoneNumber.keyboardType = .numberPad
        pincode.keyboardType = .numberPad
        userEmail.keyboardType = .emailAddress

        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.lightGray.cgColor

        setupTextFields()
        configureScreenMode()
        updateLocationFieldAvailability()
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
        country.text = UserCache.country()
        state.text = UserCache.state()
        city.text = UserCache.city()
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
        countryDropdownImage.isHidden = !isEditable
        stateDropdownImage.isHidden = !isEditable
        cityDropdownImage.isHidden = !isEditable

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
        city.isUserInteractionEnabled = false
        profileImage.isUserInteractionEnabled = isEditable

        applyFieldAppearance(isEditable: isEditable)
        updateLocationFieldAvailability()

        if isEditable {
            textFieldDidChange()
        } else {
            enableSaveButton(false)
        }
    }

    func fetchCountriesIfNeeded() {
        guard selectedRole != .institute else { return }

        viewModel.fetchCountries { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.showToastSafely(response.msg ?? "Unable to fetch countries")
                    return
                }
                self.countries = response.countries
                self.restoreExistingLocationSelectionsIfPossible()
            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func fetchStates(country: LocationCountry, shouldPresentPicker: Bool = false) {
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
                if let stateName = self.state.text,
                   let matchedState = self.states.first(where: { $0.name.caseInsensitiveCompare(stateName) == .orderedSame }) {
                    self.selectedState = matchedState
                }
                self.updateLocationFieldAvailability()
                if shouldPresentPicker {
                    self.presentStatePicker()
                } else {
                    self.fetchCitiesForExistingStateIfNeeded()
                }
            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func fetchCities(state: LocationState, shouldPresentPicker: Bool = false) {
        LoaderManager.shared.show()
        viewModel.fetchCities(request: CityListRequest(stateId: state.id)) { [weak self] result in
            guard let self else { return }
            LoaderManager.shared.hide()

            switch result {
            case .success(let response):
                guard response.isSuccess else {
                    self.resetCitySelection()
                    self.showToastSafely(response.msg ?? "No cities available")
                    return
                }
                self.cities = response.cities
                if response.cities.isEmpty {
                    self.resetCitySelection()
                    self.showToastSafely(response.msg ?? "No cities available")
                    return
                }
                if let cityName = self.city.text,
                   let matchedCity = self.cities.first(where: { $0.city.caseInsensitiveCompare(cityName) == .orderedSame }) {
                    self.selectedCity = matchedCity
                }
                self.updateLocationFieldAvailability()
                if shouldPresentPicker {
                    self.presentCityPicker()
                }
            case .failure(let error):
                self.showToastSafely(self.errorMessage(from: error))
            }
        }
    }

    func restoreExistingLocationSelectionsIfPossible() {
        guard selectedRole != .institute else { return }

        if let countryName = country.text,
           let matchedCountry = countries.first(where: { $0.name.caseInsensitiveCompare(countryName) == .orderedSame }) {
            selectedCountry = matchedCountry
            fetchStates(country: matchedCountry)
        }

        updateLocationFieldAvailability()
    }

    func fetchCitiesForExistingStateIfNeeded() {
        guard let selectedState else { return }
        fetchCities(state: selectedState)
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
        guard isEditingFromSideMenu else {
            [country, state, city].forEach {
                $0?.alpha = 1.0
                $0?.textColor = UIColor.label
            }
            return
        }

        let canSelectState = isEditingFromSideMenu && selectedCountry != nil
        let canSelectCity = isEditingFromSideMenu && selectedState != nil

        country.alpha = 1.0
        country.textColor = UIColor.label
        styleSelectionField(state, isEnabled: canSelectState)
        styleSelectionField(city, isEnabled: canSelectCity)
    }

    func styleSelectionField(_ textField: UITextField, isEnabled: Bool) {
        textField.alpha = isEnabled ? 1.0 : 0.6
        textField.textColor = isEnabled ? UIColor.label : UIColor.systemGray
    }

    func applyFieldAppearance(isEditable: Bool) {
        let editableFields = [
            userFullName,
            houseDetail,
            pincode,
            schoolName,
            grade
        ]

        let alwaysReadOnlyFields = [
            userPhoneNumber,
            userEmail,
            country,
            state,
            city
        ]

        let viewModeColor = UIColor.label
        let editModeColor = UIColor.systemGray

        editableFields.forEach {
            $0?.alpha = 1.0
            $0?.textColor = isEditable ? viewModeColor : viewModeColor
        }

        alwaysReadOnlyFields.forEach {
            $0?.alpha = 1.0
            $0?.textColor = isEditable ? editModeColor : viewModeColor
        }
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
            self.fetchStates(country: selectedCountry, shouldPresentPicker: true)
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
            self.fetchCities(state: selectedState, shouldPresentPicker: true)
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

extension UpdateProfileViewController {

    @IBAction func countryDropdownButtonTapped(_ sender: UIButton) {
        guard isEditingFromSideMenu else { return }

        if countries.isEmpty {
            fetchCountriesIfNeeded()
            return
        }

        presentCountryPicker()
    }

    @IBAction func stateDropdownButtonTapped(_ sender: UIButton) {
        guard isEditingFromSideMenu else { return }
        guard let selectedCountry else {
            showToastSafely("Please select country first")
            return
        }

        if states.isEmpty {
            fetchStates(country: selectedCountry, shouldPresentPicker: true)
            return
        }

        presentStatePicker()
    }

    @IBAction func cityDropdownTapped(_ sender: UIButton) {
        guard isEditingFromSideMenu else { return }
        guard let selectedState else {
            showToastSafely("Please select state first")
            return
        }

        if cities.isEmpty {
            fetchCities(state: selectedState, shouldPresentPicker: true)
            return
        }

        presentCityPicker()
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

        let hasValidLocation = selectedRole == .institute ||
            (selectedCountry != nil && selectedState != nil && selectedCity != nil)

        let hasValidRequiredFields = !name.isEmpty &&
            email.isValidEmail() &&
            isValidMobile(phone) &&
            hasValidLocation

        let hasProfileImageChange = selectedProfileImageData != nil

        enableSaveButton(hasValidRequiredFields || hasProfileImageChange)
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
        let countryValue = selectedRole == .institute ? "" : (country.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let stateValue = selectedRole == .institute ? "" : (state.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cityValue = selectedRole == .institute ? "" : (city.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pincodeValue = (pincode.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let latitudeValue = UserCache.latitude()
        let longitudeValue = UserCache.longitude()
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
                    latitude: latitudeValue,
                    longitude: longitudeValue,
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

        textFieldDidChange()
        dismiss(animated: true)
    }
}

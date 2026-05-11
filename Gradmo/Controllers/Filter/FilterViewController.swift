//
//  FilterViewController.swift
//  Gradmo
//
//  Created by Philanderer on 29/03/26.
//

import UIKit

enum InstituteSortOption {
    case aToZ
    case zToA
}

enum InstituteModeOption {
    case offline
    case online
}

struct InstituteFilterState {
    var sort: InstituteSortOption?
    var mode: InstituteModeOption?
    var city: String?

    var hasSelection: Bool {
        sort != nil || mode != nil || !(city ?? "").isEmpty
    }
}

final class InstituteFilterSession {
    static let shared = InstituteFilterSession()

    var current = InstituteFilterState()

    private init() {}

    func clear() {
        current = InstituteFilterState()
    }
}

final class FilterViewController: UIViewController {

    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var aTOzRadiobutton: UIButton!
    @IBOutlet private weak var zTOaRadiobutton: UIButton!
    @IBOutlet private weak var offlineRadiobutton: UIButton!
    @IBOutlet private weak var onlineRadiobutton: UIButton!
    @IBOutlet private weak var cityDropdownButton: UIButton!
    @IBOutlet private weak var cityTextfield: UITextField!
    @IBOutlet private weak var applyFilterButton: UIButton!
    @IBOutlet private weak var clearFilterButton: UIButton!
    @IBOutlet private weak var modeLabel: UILabel!
    @IBOutlet private weak var sortByLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var filterResultsLabel: UILabel!

    private var cities: [String] = []

    var onApplyFilters: ((InstituteFilterState) -> Void)?
    var onClearFilters: (() -> Void)?

    private var selectedSort: InstituteSortOption?
    private var selectedMode: InstituteModeOption?
    private var selectedCity: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        restoreSavedFilters()
        setupUI()
        configureSheetPresentationIfNeeded()
    }
}

private extension FilterViewController {
    func restoreSavedFilters() {
        let savedFilters = InstituteFilterSession.shared.current
        selectedSort = savedFilters.sort
        selectedMode = savedFilters.mode
        selectedCity = savedFilters.city
    }

    func setupUI() {
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        mainView.layer.cornerRadius = 24
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cityTextfield.isUserInteractionEnabled = false
        cityTextfield.setLeftPaddingPoints(12)
        cityTextfield.text = nil

        filterResultsLabel.font = UIFont.GilroyBold(ofSize: 18)
        sortByLabel.font = UIFont.GilroySemiBold(ofSize: 16)
        cityLabel.font = UIFont.GilroySemiBold(ofSize: 16)
        modeLabel.font = UIFont.GilroySemiBold(ofSize: 16)
        cityTextfield.font = UIFont.GilroyRegular(ofSize: 14)
        applyFilterButton.titleLabel?.font = UIFont.GilroySemiBold(ofSize: 15)
        clearFilterButton.titleLabel?.font = UIFont.GilroySemiBold(ofSize: 15)

        applyFilterButton.applyCapsuleCornerRadius()
        clearFilterButton.applyCapsuleCornerRadius()
        updateSelectionUI()
        updateApplyButton()
    }

    func configureSheetPresentationIfNeeded() {
        modalPresentationStyle = .pageSheet

        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 24
            sheet.largestUndimmedDetentIdentifier = nil
        }
    }

    func updateSelectionUI() {
        updateRadioButton(aTOzRadiobutton, isSelected: selectedSort == .aToZ)
        updateRadioButton(zTOaRadiobutton, isSelected: selectedSort == .zToA)
        updateRadioButton(offlineRadiobutton, isSelected: selectedMode == .offline)
        updateRadioButton(onlineRadiobutton, isSelected: selectedMode == .online)
        cityTextfield.text = selectedCity
    }

    func updateRadioButton(_ button: UIButton, isSelected: Bool) {
        let imageName = isSelected ? "RadioButtonSelected" : "RadioButtonUnselected"
        button.setImage(UIImage(named: imageName), for: .normal)
    }

    func updateApplyButton() {
        applyFilterButton.setEnabledStyle(currentFilters.hasSelection)
        clearFilterButton.setEnabledStyle(currentFilters.hasSelection)
    }

    var currentFilters: InstituteFilterState {
        InstituteFilterState(
            sort: selectedSort,
            mode: selectedMode,
            city: selectedCity
        )
    }

    func openCityPicker() {
        guard !cities.isEmpty else {
            showToastSafely("No cities available")
            return
        }

        let viewController = StatePickerViewController()
        viewController.states = cities
        viewController.screenTitle = "Select City"
        viewController.searchPlaceholder = "Search City"
        viewController.onStateSelected = { [weak self] city in
            guard let self else { return }
            self.selectedCity = city
            self.updateSelectionUI()
            self.updateApplyButton()
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }

    func handleCityDropdownTap() {
        if !cities.isEmpty {
            openCityPicker()
            return
        }

        fetchInstituteCities()
    }

    func fetchInstituteCities() {
        Task { [weak self] in
            do {
                let response = try await InstituteCityListService.fetchCities()

                await MainActor.run {
                    guard let self else { return }
                    guard response.isSuccess else {
                        self.showToastSafely(response.msg ?? "Unable to fetch cities")
                        return
                    }

                    self.cities = response.cities
                        .map { $0.city.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }

                    guard !self.cities.isEmpty else {
                        self.showToastSafely(response.msg ?? "No cities available")
                        return
                    }

                    self.openCityPicker()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showToastSafely(self?.errorMessage(from: error) ?? "Unable to fetch cities")
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

extension FilterViewController {
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func sortAToZTapped(_ sender: UIButton) {
        selectedSort = selectedSort == .aToZ ? nil : .aToZ
        updateSelectionUI()
        updateApplyButton()
    }

    @IBAction func sortZToATapped(_ sender: UIButton) {
        selectedSort = selectedSort == .zToA ? nil : .zToA
        updateSelectionUI()
        updateApplyButton()
    }

    @IBAction func offlineTapped(_ sender: UIButton) {
        selectedMode = selectedMode == .offline ? nil : .offline
        updateSelectionUI()
        updateApplyButton()
    }

    @IBAction func onlineTapped(_ sender: UIButton) {
        selectedMode = selectedMode == .online ? nil : .online
        updateSelectionUI()
        updateApplyButton()
    }

    @IBAction func cityDropdownTapped(_ sender: UIButton) {
        handleCityDropdownTap()
    }

    @IBAction func applyFilterTapped(_ sender: UIButton) {
        guard applyFilterButton.isUserInteractionEnabled else { return }
        let filters = currentFilters
        InstituteFilterSession.shared.current = filters
        onApplyFilters?(filters)
        dismiss(animated: true)
    }
    
    @IBAction func clearFilterButtonTapped(_ sender: UIButton!){
        selectedSort = nil
        selectedMode = nil
        selectedCity = nil
        updateSelectionUI()
        updateApplyButton()
        InstituteFilterSession.shared.clear()
        onClearFilters?()
        dismiss(animated: true)
    }
}

//
//  FilterViewController.swift
//  Gradmo
//
//  Created by Philanderer on 29/03/26.
//

import UIKit

final class FilterViewController: UIViewController {

    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var aTOzRadiobutton: UIButton!
    @IBOutlet private weak var zTOaRadiobutton: UIButton!
    @IBOutlet private weak var offlineRadiobutton: UIButton!
    @IBOutlet private weak var onlineRadiobutton: UIButton!
    @IBOutlet private weak var cityDropdownButton: UIButton!
    @IBOutlet private weak var cityTextfield: UITextField!
    @IBOutlet private weak var applyFilterButton: UIButton!
    @IBOutlet private weak var modeLabel: UILabel!
    @IBOutlet private weak var sortByLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var filterResultsLabel: UILabel!

    private let cities = [
        "Kolkata", "Howrah", "New Town", "Salt Lake", "Park Street",
        "Delhi", "Mumbai", "Bengaluru", "Chennai", "Hyderabad"
    ]

    private enum SortOption {
        case aToZ
        case zToA
    }

    private enum ModeOption {
        case offline
        case online
    }

    private var selectedSort: SortOption?
    private var selectedMode: ModeOption?
    private var selectedCity: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSheetPresentationIfNeeded()
    }
}

private extension FilterViewController {
    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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

        applyFilterButton.applyCapsuleCornerRadius()
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
        let hasSelection = selectedSort != nil || selectedMode != nil || !(selectedCity ?? "").isEmpty
        applyFilterButton.setEnabledStyle(hasSelection)
    }

    func openCityPicker() {
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
        openCityPicker()
    }

    @IBAction func applyFilterTapped(_ sender: UIButton) {
        guard applyFilterButton.isUserInteractionEnabled else { return }
        dismiss(animated: true)
    }
}

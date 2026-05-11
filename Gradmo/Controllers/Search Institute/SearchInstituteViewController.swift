//
//  SearchInstituteViewController.swift
//  Gradmo
//
//  Created by Philanderer on 29/03/26.
//

import UIKit

final class SearchInstituteViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var bannerCollectionView: UICollectionView!
    @IBOutlet private weak var resultsLabel: UILabel!
    @IBOutlet private weak var instituteTableView: UITableView!

    private var bannerItems: [BannerSliderItem] = []
    private var displayedInstitutes: [InstituteListingItem] = []
    private var lastResponse: InstituteListingResponse?
    private var appliedSearchText: String = ""
    private var bannerAutoScrollTimer: Timer?
    private var currentBannerIndex = 0
    private var instituteFetchTask: Task<Void, Never>?

    var screenTitleText: String = "Institutes"
    var shouldShowBackButton: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTableView()
        fetchBannerItems()
        fetchInstitutes()
        startBannerAutoScroll()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTextField.layer.cornerRadius = searchTextField.frame.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startBannerAutoScroll()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopBannerAutoScroll()
    }

    deinit {
        bannerAutoScrollTimer?.invalidate()
        instituteFetchTask?.cancel()
    }
}

private extension SearchInstituteViewController {
    func fetchBannerItems() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let banners = try await BannerSliderService.fetchBanners()
                await MainActor.run {
                    self.applyBannerItems(banners)
                }
            } catch {
                await MainActor.run {
                    self.applyBannerItems([])
                }
            }
        }
    }

    func applyBannerItems(_ items: [BannerSliderItem]) {
        stopBannerAutoScroll()
        bannerItems = items
        currentBannerIndex = 0
        bannerCollectionView.reloadData()
        if !items.isEmpty {
            bannerCollectionView.setContentOffset(.zero, animated: false)
        }
        startBannerAutoScroll()
    }

    func setupUI() {
        headerLabel.text = screenTitleText
        backButton.isHidden = !shouldShowBackButton
        searchTextField.setLeftPaddingPoints(40)
        searchTextField.setRightPaddingPoints(15)
        searchTextField.layer.masksToBounds = true
        searchTextField.keyboardType = .default
        searchTextField.returnKeyType = .done
        searchTextField.delegate = self

        instituteTableView.backgroundColor = .clear
    }

    func fetchInstitutes() {
        instituteFetchTask?.cancel()
        let request = makeInstituteListingRequest()

        instituteFetchTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await InstituteListingService.fetchInstitutes(request: request)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.applyInstituteResponse(response)
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.lastResponse = nil
                    self.displayedInstitutes = []
                    self.resultsLabel.text = "Showing 0 results"
                    self.instituteTableView.reloadData()
                    self.showToastSafely((error as? LocalizedError)?.errorDescription ?? "Unable to fetch institutes")
                }
            }
        }
    }

    func makeInstituteListingRequest() -> InstituteListingRequest {
        let filters = InstituteFilterSession.shared.current

        var orderField: String?
        var orderType: String?

        if let selectedSort = filters.sort {
            orderField = "name"
            switch selectedSort {
            case .aToZ:
                orderType = "ASC"
            case .zToA:
                orderType = "DESC"
            }
        }

        let selectedCity = sanitized(filters.city)
        let searchText = sanitized(appliedSearchText)

        return InstituteListingRequest(
            batchID: nil,
            latitude: sanitized(UserCache.latitude()),
            longitude: sanitized(UserCache.longitude()),
            orderField: orderField,
            orderType: orderType,
            search: searchText,
            city: selectedCity
        )
    }

    func applyInstituteResponse(_ response: InstituteListingResponse) {
        lastResponse = response
        displayedInstitutes = response.institutes
        let totalResults = response.pagination?.totalRecords ?? response.institutes.count
        resultsLabel.text = "Showing \(displayedInstitutes.count) of \(totalResults) results"
        instituteTableView.reloadData()

        if displayedInstitutes.isEmpty, let message = response.msg, !message.isEmpty {
            showToastSafely(message)
        }
    }

    func sanitized(_ value: String?) -> String? {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    func setupCollectionView() {
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        bannerCollectionView.registerXib(BannerCollectionViewCell.self)
        bannerCollectionView.showsHorizontalScrollIndicator = false
        bannerCollectionView.decelerationRate = .fast
    }

    func setupTableView() {
        instituteTableView.delegate = self
        instituteTableView.dataSource = self
        instituteTableView.registerXib(SearchInstituteTableViewCell.self)
        instituteTableView.separatorStyle = .none
        instituteTableView.showsVerticalScrollIndicator = false
        instituteTableView.rowHeight = UITableView.automaticDimension
        instituteTableView.estimatedRowHeight = 127
    }

    func startBannerAutoScroll() {
        guard bannerAutoScrollTimer == nil, bannerItems.count > 1 else { return }

        let timer = Timer(timeInterval: 5,
                          target: self,
                          selector: #selector(scrollToNextBanner),
                          userInfo: nil,
                          repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        bannerAutoScrollTimer = timer
    }

    func stopBannerAutoScroll() {
        bannerAutoScrollTimer?.invalidate()
        bannerAutoScrollTimer = nil
    }

    @objc func scrollToNextBanner() {
        guard !bannerItems.isEmpty else { return }
        let nextIndex = (currentBannerIndex + 1) % bannerItems.count
        scrollBanner(to: nextIndex, animated: true)
    }

    func scrollBanner(to index: Int, animated: Bool) {
        guard index >= 0, index < bannerItems.count else { return }
        currentBannerIndex = index
        bannerCollectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .left,
            animated: animated
        )
    }

    func bannerCardWidth(for collectionView: UICollectionView) -> CGFloat {
        return collectionView.bounds.width
    }

    func updateCurrentBannerIndex() {
        let pageWidth = bannerCardWidth(for: bannerCollectionView)
        guard pageWidth > 0 else { return }

        let index = Int(round(bannerCollectionView.contentOffset.x / pageWidth))
        currentBannerIndex = max(0, min(index, bannerItems.count - 1))
    }
}

extension SearchInstituteViewController {
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton!){
        let vc = storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        vc.modalPresentationStyle = .pageSheet
        vc.onApplyFilters = { [weak self] _ in
            self?.fetchInstitutes()
        }
        vc.onClearFilters = { [weak self] in
            self?.fetchInstitutes()
        }
        present(vc, animated: true)
    }
}

extension SearchInstituteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == searchTextField else {
            textField.resignFirstResponder()
            return true
        }

        appliedSearchText = textField.text ?? ""
        fetchInstitutes()
        textField.resignFirstResponder()
        return true
    }
}

extension SearchInstituteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedInstitutes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: SearchInstituteTableViewCell.self),
            for: indexPath
        ) as? SearchInstituteTableViewCell else {
            return UITableViewCell()
        }

        let institute = displayedInstitutes[indexPath.row]
        cell.configure(
            name: institute.name,
            address: institute.formattedAddress,
            rating: institute.displayRating,
            instituteID: institute.displayID,
            imageURL: institute.imageURL,
            placeholderImage: UIImage(named: "institutePlaceholder"),
            showsOnline: institute.supportsOnline,
            showsOffline: institute.supportsOffline,
            showsHybrid: institute.supportsHybrid
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let institute = displayedInstitutes[indexPath.row]
        guard let instituteDetailsViewController = storyboard?.instantiateViewController(
            withIdentifier: "InstituteDetailsViewController"
        ) as? InstituteDetailsViewController else {
            return
        }

        instituteDetailsViewController.selectedInstituteID = institute.instituteID
        instituteDetailsViewController.instituteNameText = institute.name
        instituteDetailsViewController.instituteAddressText = institute.formattedAddress
        instituteDetailsViewController.instituteImageURLText = institute.imageURL
        instituteDetailsViewController.instituteRatingText = institute.displayRating
        instituteDetailsViewController.instituteMobileNumberText = sanitized(institute.mobile) ?? "Not available"
        instituteDetailsViewController.instituteEmailText = sanitized(institute.email) ?? "Not available"
        instituteDetailsViewController.hidesBottomBarWhenPushed = shouldHideTabBarForInstituteDetailsNavigation()

        navigationController?.pushViewController(instituteDetailsViewController, animated: true)
    }

    private func shouldHideTabBarForInstituteDetailsNavigation() -> Bool {
        guard let tabBarController else {
            return false
        }

        return tabBarController.selectedIndex == CustomTabBarController.AppTab.secondary.rawValue
            && !shouldShowBackButton
    }
}

extension SearchInstituteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bannerItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: BannerCollectionViewCell.self),for: indexPath) as? BannerCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(
            imageURL: bannerItems[indexPath.item].imageURL,
            placeholder: UIImage(named: "bannerPlaceholder")
        )
        cell.bannerImageView.layer.cornerRadius = 0
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: bannerCardWidth(for: collectionView), height: 170)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == bannerCollectionView {
            stopBannerAutoScroll()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == bannerCollectionView, !decelerate {
            updateCurrentBannerIndex()
            startBannerAutoScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == bannerCollectionView {
            updateCurrentBannerIndex()
            startBannerAutoScroll()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == bannerCollectionView {
            updateCurrentBannerIndex()
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == bannerCollectionView else { return }

        let pageWidth = bannerCardWidth(for: bannerCollectionView)
        guard pageWidth > 0 else { return }

        let index = max(0, min(Int(round(targetContentOffset.pointee.x / pageWidth)), bannerItems.count - 1))
        targetContentOffset.pointee.x = CGFloat(index) * pageWidth
        currentBannerIndex = index
    }
}

//
//  HomeViewController.swift
//  Gradmo
//
//  Created by Philanderer on 14/03/26.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var bannerCollectionView: UICollectionView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
//Student View outlets
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var totalEnrollmentInBatchesCountLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchScreenButton: UIButton!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var nearByInstituteCollectionView: UICollectionView!
    
//Teacher View Outlets
    @IBOutlet weak var teacherView:UIView!
    @IBOutlet weak var myBatchesLabel: UILabel!
    @IBOutlet weak var searchTeacherViewTextField: UITextField!
    @IBOutlet weak var myBatchesTableView: UITableView!
    
    private var bannerItems: [BannerSliderItem] = []

    private var bannerAutoScrollTimer: Timer?
    private var currentBannerIndex = 0
    private var hasInitializedInfiniteBannerPosition = false
    private var blurOverlayView: UIControl?
    private var sideMenuContainerView: UIView?
    private var sideMenuLeadingConstraint: NSLayoutConstraint?
    private var sideMenuWidthConstraint: NSLayoutConstraint?
    private var sideMenuBottomConstraint: NSLayoutConstraint?
    private var overlayBottomConstraint: NSLayoutConstraint?
    private var sideMenuViewController: SideMenuViewController?
    private var isSideMenuVisible = false
    private let bannerLoopMultiplier = 200
    private var nearbyInstitutes: [InstituteListingItem] = []
    private var nearbyInstituteFetchTask: Task<Void, Never>?
    private var enrolledBatchCountTask: Task<Void, Never>?
    private var teacherBatchListTask: Task<Void, Never>?
    private var hasRefreshedAppDefaults = false

    private var myBatches: [TeacherBatch] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchBannerItems()
        startBannerAutoScroll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureHomeViewForCurrentRole()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureInfiniteBannerStartIfNeeded()
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
        nearbyInstituteFetchTask?.cancel()
        enrolledBatchCountTask?.cancel()
        teacherBatchListTask?.cancel()
    }
    
    @IBAction func sideMenuButtonTapped(_ sender: UIButton!){
        showSideMenu()
    }
    
    
//    StudentView Button
    @IBAction func seeAllButtonTapped(_ sender: UIButton!){
        openSearchInstituteScreen(title: "Institutes")
    }
    
    @IBAction func searchStudentViewButtonTapped(_ sender: UIButton!){
        openSearchInstituteScreen(title: "Search Institute")
    }
    
}

extension HomeViewController{
    private struct TeacherBatch {
        let batchID: Int?
        let name: String
        let teacherName: String
        let timing: String
        let image: UIImage?
        let imageURL: String?
        let description: String?
    }

    func fetchBannerItems() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let banners = try await BannerSliderService.fetchBanners()
                await MainActor.run {
                    self.applyBannerItems(banners)
                    self.refreshAppDefaultsAfterFirstHomeAPI()
                }
            } catch {
                await MainActor.run {
                    self.applyBannerItems([])
                    self.refreshAppDefaultsAfterFirstHomeAPI()
                }
            }
        }
    }

    func applyBannerItems(_ items: [BannerSliderItem]) {
        stopBannerAutoScroll()
        bannerItems = items
        currentBannerIndex = 0
        hasInitializedInfiniteBannerPosition = false
        bannerCollectionView.reloadData()
        bannerCollectionView.layoutIfNeeded()
        configureInfiniteBannerStartIfNeeded()
        startBannerAutoScroll()
    }

    func refreshAppDefaultsAfterFirstHomeAPI() {
        guard !hasRefreshedAppDefaults else { return }
        hasRefreshedAppDefaults = true
        AppDefaultsService.refreshIfAuthenticated()
    }

    func configureHomeViewForCurrentRole() {
        switch UserCache.getUserRole() {
        case .teacher:
            studentView.isHidden = true
            teacherView.isHidden = false
            setupTeacherView()
        case .student, .institute:
            studentView.isHidden = false
            teacherView.isHidden = true
            setupStudentView()
        }
    }

    func setupSharedHeader() {
        let fullName = UserCache.fullName()
        userNameLabel.text = fullName.isEmpty ? "Hi" : "Hi, \(fullName)"
//        profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.height / 2
        profilePicImageView.clipsToBounds = true

//        if let imageURL = URL(string: UserCache.profileImageURL()), !UserCache.profileImageURL().isEmpty {
//            profilePicImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "profilePic"))
//        } else {
//            profilePicImageView.image = UIImage(named: "profilePic")
//        }
    }

    func setupStudentView() {
        setupSharedHeader()
        updateEnrollmentCountLabel(count: nil)
        searchTextField.placeholder = "Search an institute to enroll"
        searchTextField.delegate = self
        searchTextField.setLeftPaddingPoints(40)
        searchTextField.setRightPaddingPoints(15)
        searchTextField.layer.cornerRadius = self.searchTextField.frame.height / 2
        searchTextField.layer.masksToBounds = true
        seeAllButton.setTitle("See all", for: .normal)
        fetchEnrolledBatchCount()
        fetchNearbyInstitutes()
    }
    
    func setupTeacherView() {
        setupSharedHeader()
        myBatchesLabel.text = "My Batches"
        searchTeacherViewTextField.placeholder = "Search a batch"
        searchTeacherViewTextField.setLeftPaddingPoints(40)
        searchTeacherViewTextField.setRightPaddingPoints(15)
        searchTeacherViewTextField.layer.cornerRadius = self.searchTeacherViewTextField.frame.height / 2
        searchTeacherViewTextField.layer.masksToBounds = true
        myBatchesTableView.reloadData()
        fetchTeacherBatches()
    }

    func openTeacherAttendanceScreen() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let teacherAttendanceViewController = storyboard.instantiateViewController(
            withIdentifier: "TeacherAttendanceViewController"
        ) as? TeacherAttendanceViewController else {
            return
        }

        teacherAttendanceViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(teacherAttendanceViewController, animated: true)
    }

    func openCreateAssessmentScreen() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let createAssessmentViewController = storyboard.instantiateViewController(
            withIdentifier: "CreateAssessmentViewController"
        ) as? CreateAssessmentViewController else {
            return
        }

        createAssessmentViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(createAssessmentViewController, animated: true)
    }

    private func openBatchDetails(for batch: TeacherBatch) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let batchDetailViewController = storyboard.instantiateViewController(
            withIdentifier: "BatchDetailViewController"
        ) as? BatchDetailViewController else {
            return
        }

        batchDetailViewController.batchDetail = .init(
            batchID: batch.batchID,
            instituteName: "Gradmo",
            batchName: batch.name,
            teacherName: batch.teacherName,
            time: batch.timing,
            rating: "4.8",
            subject: "Commerce",
            grade: "Grade 12",
            image: batch.image,
            imageURL: batch.imageURL,
            batchPriceText: nil,
            batchOfferPriceText: nil
        )
        batchDetailViewController.selectedBatchID = batch.batchID
        batchDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(batchDetailViewController, animated: true)
    }

    func setupCollectionView(){
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        bannerCollectionView.registerXib(BannerCollectionViewCell.self)
        bannerCollectionView.showsHorizontalScrollIndicator = false
        bannerCollectionView.decelerationRate = .fast
//        bannerCollectionView.isUserInteractionEnabled = false
//        bannerCollectionView.isScrollEnabled = false

        nearByInstituteCollectionView.delegate = self
        nearByInstituteCollectionView.dataSource = self
        nearByInstituteCollectionView.registerXib(InstituteDetailCollectionViewCell.self)
        nearByInstituteCollectionView.showsHorizontalScrollIndicator = false

        myBatchesTableView.delegate = self
        myBatchesTableView.dataSource = self
        myBatchesTableView.registerXib(MyBatchesTableViewCell.self)
        myBatchesTableView.separatorStyle = .none
        myBatchesTableView.backgroundColor = .clear
        myBatchesTableView.showsVerticalScrollIndicator = false
        myBatchesTableView.rowHeight = UITableView.automaticDimension
        myBatchesTableView.estimatedRowHeight = 80
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
        let nextIndex = currentBannerIndex + 1
        scrollBanner(to: nextIndex, animated: true)
    }

    func scrollBanner(to index: Int, animated: Bool) {
        guard totalBannerItemCount > 0 else { return }
        let boundedIndex = max(0, min(index, totalBannerItemCount - 1))
        let normalizedIndex = normalizedBannerIndex(for: boundedIndex)
        currentBannerIndex = normalizedIndex
        let pageWidth = bannerScrollStep(for: bannerCollectionView)
        let targetOffsetX = CGFloat(normalizedIndex) * pageWidth - bannerSectionInsets(for: bannerCollectionView).left
        let boundedOffsetX = max(-bannerCollectionView.adjustedContentInset.left, targetOffsetX)
        bannerCollectionView.setContentOffset(CGPoint(x: boundedOffsetX, y: 0), animated: animated)
    }

    func bannerCardWidth(for collectionView: UICollectionView) -> CGFloat {
        return collectionView.bounds.width
    }

    func bannerSpacing(for collectionView: UICollectionView) -> CGFloat {
        return 0
    }

    func bannerSectionInsets(for collectionView: UICollectionView) -> UIEdgeInsets {
        return .zero
    }

    func bannerScrollStep(for collectionView: UICollectionView) -> CGFloat {
        return bannerCardWidth(for: collectionView) + bannerSpacing(for: collectionView)
    }

    func updateCurrentBannerIndex() {
        let pageWidth = bannerScrollStep(for: bannerCollectionView)
        guard pageWidth > 0 else { return }
        guard totalBannerItemCount > 0 else { return }

        let adjustedOffset = bannerCollectionView.contentOffset.x + bannerSectionInsets(for: bannerCollectionView).left
        let index = Int(round(adjustedOffset / pageWidth))
        currentBannerIndex = max(0, min(index, totalBannerItemCount - 1))
        recenterBannerIfNeeded()
    }

    var totalBannerItemCount: Int {
        guard bannerItems.count > 1 else { return bannerItems.count }
        return bannerItems.count * bannerLoopMultiplier
    }

    func bannerDataIndex(for index: Int) -> Int {
        guard !bannerItems.isEmpty else { return 0 }
        let remainder = index % bannerItems.count
        return remainder >= 0 ? remainder : remainder + bannerItems.count
    }

    func bannerMidpointIndex() -> Int {
        guard totalBannerItemCount > 0 else { return 0 }
        let midpointBlock = (bannerLoopMultiplier / 2) * bannerItems.count
        return min(midpointBlock, totalBannerItemCount - 1)
    }

    func normalizedBannerIndex(for index: Int) -> Int {
        guard totalBannerItemCount > 0, bannerItems.count > 1 else { return index }
        return min(bannerMidpointIndex() + bannerDataIndex(for: index), totalBannerItemCount - 1)
    }

    func configureInfiniteBannerStartIfNeeded() {
        guard !hasInitializedInfiniteBannerPosition else { return }
        guard bannerCollectionView.bounds.width > 0 else { return }
        guard totalBannerItemCount > 1 else { return }

        hasInitializedInfiniteBannerPosition = true
        currentBannerIndex = bannerMidpointIndex()
        bannerCollectionView.reloadData()
        bannerCollectionView.layoutIfNeeded()
        scrollBanner(to: currentBannerIndex, animated: false)
    }

    func recenterBannerIfNeeded() {
        guard totalBannerItemCount > 1 else { return }

        let normalizedIndex = normalizedBannerIndex(for: currentBannerIndex)
        guard normalizedIndex != currentBannerIndex else { return }

        currentBannerIndex = normalizedIndex
        let pageWidth = bannerScrollStep(for: bannerCollectionView)
        let targetOffsetX = CGFloat(normalizedIndex) * pageWidth - bannerSectionInsets(for: bannerCollectionView).left
        let boundedOffsetX = max(-bannerCollectionView.adjustedContentInset.left, targetOffsetX)
        bannerCollectionView.setContentOffset(CGPoint(x: boundedOffsetX, y: 0), animated: false)
    }

    func showSideMenu() {
        guard !isSideMenuVisible else { return }
        isSideMenuVisible = true

        if sideMenuContainerView == nil {
            setupSideMenuPresentation()
        }

        let menuWidth = view.bounds.width * 0.85
        let bottomExtension = sideMenuBottomExtension()
        sideMenuWidthConstraint?.constant = menuWidth
        sideMenuLeadingConstraint?.constant = 0
        sideMenuBottomConstraint?.constant = bottomExtension
        overlayBottomConstraint?.constant = bottomExtension
        blurOverlayView?.isHidden = false
        tabBarController?.tabBar.isHidden = true

        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.blurOverlayView?.alpha = 3
            self.view.layoutIfNeeded()
        }
    }

    func hideSideMenu() {
        guard isSideMenuVisible else { return }
        isSideMenuVisible = false

        let menuWidth = sideMenuWidthConstraint?.constant ?? (view.bounds.width * 0.75)
        let bottomExtension = sideMenuBottomExtension()
        sideMenuLeadingConstraint?.constant = -menuWidth
        sideMenuBottomConstraint?.constant = bottomExtension
        overlayBottomConstraint?.constant = bottomExtension

        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseIn]) {
            self.blurOverlayView?.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.blurOverlayView?.isHidden = true
            self.tabBarController?.tabBar.isHidden = false
        }
    }

    func setupSideMenuPresentation() {
        let overlay = UIControl()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = .clear
        overlay.alpha = 1
        overlay.isHidden = true
        overlay.addTarget(self, action: #selector(overlayTapped), for: .touchUpInside)

        let menuContainer = UIView()
        menuContainer.translatesAutoresizingMaskIntoConstraints = false
        menuContainer.backgroundColor = .white
        menuContainer.layer.shadowColor = UIColor.black.cgColor
        menuContainer.layer.shadowOpacity = 0.18
        menuContainer.layer.shadowRadius = 12
        menuContainer.layer.shadowOffset = CGSize(width: 4, height: 0)
        menuContainer.layer.cornerRadius = 0

        view.addSubview(overlay)
        view.addSubview(menuContainer)

        let menuWidth = view.bounds.width * 0.85
        let bottomExtension = sideMenuBottomExtension()
        let leading = menuContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -menuWidth)
        let width = menuContainer.widthAnchor.constraint(equalToConstant: menuWidth)
        let overlayBottom = overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomExtension)
        let menuBottom = menuContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomExtension)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayBottom,

            leading,
            menuContainer.topAnchor.constraint(equalTo: view.topAnchor),
            menuBottom,
            width
        ])

        let sideMenuVC = UIStoryboard(name: "Home", bundle: nil)
            .instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        addChild(sideMenuVC)
        menuContainer.addSubview(sideMenuVC.view)
        sideMenuVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideMenuVC.view.topAnchor.constraint(equalTo: menuContainer.topAnchor),
            sideMenuVC.view.leadingAnchor.constraint(equalTo: menuContainer.leadingAnchor),
            sideMenuVC.view.trailingAnchor.constraint(equalTo: menuContainer.trailingAnchor),
            sideMenuVC.view.bottomAnchor.constraint(equalTo: menuContainer.bottomAnchor)
        ])
        sideMenuVC.didMove(toParent: self)

        let swipeToClose = UISwipeGestureRecognizer(target: self, action: #selector(menuSwipedLeft))
        swipeToClose.direction = .left
        swipeToClose.cancelsTouchesInView = false
        menuContainer.addGestureRecognizer(swipeToClose)

        let swipeOverlayToClose = UISwipeGestureRecognizer(target: self, action: #selector(menuSwipedLeft))
        swipeOverlayToClose.direction = .left
        overlay.addGestureRecognizer(swipeOverlayToClose)

        blurOverlayView = overlay
        sideMenuContainerView = menuContainer
        sideMenuLeadingConstraint = leading
        sideMenuWidthConstraint = width
        sideMenuBottomConstraint = menuBottom
        overlayBottomConstraint = overlayBottom
        sideMenuViewController = sideMenuVC
    }

    func sideMenuBottomExtension() -> CGFloat {
        guard let tabBarRootView = tabBarController?.view else {
            return 0
        }

        let homeViewBottom = view.convert(view.bounds, to: tabBarRootView).maxY
        return max(0, tabBarRootView.bounds.maxY - homeViewBottom)
    }

    @objc func overlayTapped() {
        hideSideMenu()
    }

    @objc func menuSwipedLeft() {
        hideSideMenu()
    }

    func openSearchInstituteScreen(title: String = "Institutes") {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "SearchInstituteViewController"
        ) as! SearchInstituteViewController
        viewController.screenTitleText = title
        viewController.shouldShowBackButton = true
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    func fetchNearbyInstitutes() {
        nearbyInstituteFetchTask?.cancel()

        let request = InstituteListingRequest(
            batchID: nil,
            latitude: sanitized(UserCache.latitude()),
            longitude: sanitized(UserCache.longitude()),
            orderField: nil,
            orderType: nil,
            search: nil,
            city: nil
        )

        nearbyInstituteFetchTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await InstituteListingService.fetchInstitutes(request: request)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.nearbyInstitutes = Array(response.institutes.prefix(4))
                    self.nearByInstituteCollectionView.reloadData()
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.nearbyInstitutes = []
                    self.nearByInstituteCollectionView.reloadData()
                }
            }
        }
    }

    func fetchEnrolledBatchCount() {
        enrolledBatchCountTask?.cancel()
        enrolledBatchCountTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await BatchListService.fetchEnrolledBatches()
                guard !Task.isCancelled else { return }

                let status = response.status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let isSuccess = status == "true" || status == "1" || status == "success"
                let count = isSuccess ? self.enrolledBatchCount(from: response) : 0

                await MainActor.run {
                    self.updateEnrollmentCountLabel(count: count)
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.updateEnrollmentCountLabel(count: 0)
                }
            }
        }
    }

    func fetchTeacherBatches() {
        teacherBatchListTask?.cancel()
        teacherBatchListTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await BatchListService.fetchEnrolledBatches(
                    parameters: [
                        "page": 1,
                        "limit": 10,
                        "list": "All"
                    ]
                )
                guard !Task.isCancelled else { return }

                let status = response.status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let isSuccess = status == "true" || status == "1" || status == "success"
                let batches = isSuccess ? self.teacherBatches(from: response.data?.enrolledBatches ?? []) : []

                await MainActor.run {
                    self.myBatches = batches
                    self.myBatchesTableView.reloadData()
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.myBatches = []
                    self.myBatchesTableView.reloadData()
                }
            }
        }
    }

    func enrolledBatchCount(from response: BatchListResponse) -> Int {
        response.data?.pagination?.totalRecords
            ?? response.data?.pagination?.total
            ?? response.data?.enrolledBatches.count
            ?? 0
    }

    private func teacherBatches(from items: [EnrolledBatchItem]) -> [TeacherBatch] {
        items.map { item in
            TeacherBatch(
                batchID: item.batchID,
                name: sanitized(item.batchName) ?? sanitized(item.title) ?? "Untitled Batch",
                teacherName: sanitized(item.instructor) ?? "Not available",
                timing: item.displayTiming,
                image: UIImage(named: "institutePlaceholder"),
                imageURL: sanitized(item.batchImage) ?? sanitized(item.logo),
                description: sanitized(item.description)
            )
        }
    }

    func updateEnrollmentCountLabel(count: Int?) {
        guard let count else {
            totalEnrollmentInBatchesCountLabel.text = "Checking your enrolled batches..."
            return
        }

        switch count {
        case 0:
            totalEnrollmentInBatchesCountLabel.text = "You’re not enrolled in any active batch"
        case 1:
            totalEnrollmentInBatchesCountLabel.text = "You’re enrolled in 1 active batch"
        default:
            totalEnrollmentInBatchesCountLabel.text = "You’re enrolled in \(count) active batches"
        }
    }

    func sanitized(_ value: String?) -> String? {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            openSearchInstituteScreen(title: "Search Institute")
            return false
        }

        return true
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == myBatchesTableView else { return 0 }
        return myBatches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView == myBatchesTableView,
              let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyBatchesTableViewCell.self),for: indexPath) as? MyBatchesTableViewCell else {
            return UITableViewCell()
        }

        let batch = myBatches[indexPath.row]
        cell.configure(
            batchName: batch.name,
            teacherName: batch.teacherName,
            timing: batch.timing,
            image: batch.image,
            imageURL: batch.imageURL
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == myBatchesTableView, UserCache.getUserRole() == .teacher else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        openBatchDetails(for: myBatches[indexPath.row])
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bannerCollectionView {
            return totalBannerItemCount
        }

        return nearbyInstitutes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bannerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: BannerCollectionViewCell.self),
                for: indexPath
            ) as? BannerCollectionViewCell else {
                return UICollectionViewCell()
            }

            let banner = bannerItems[bannerDataIndex(for: indexPath.item)]
            cell.configure(
                imageURL: banner.imageURL,
                placeholder: UIImage(named: "bannerPlaceholder")
            )
            cell.bannerImageView.layer.cornerRadius = 12
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: InstituteDetailCollectionViewCell.self),
            for: indexPath
        ) as? InstituteDetailCollectionViewCell else {
            return UICollectionViewCell()
        }

        let institute = nearbyInstitutes[indexPath.item]
        cell.configure(
            name: institute.name,
            address: institute.formattedAddress,
            ratingText: institute.displayRating,
            imageURL: institute.imageURL,
            placeholderImage: UIImage(named: "institutePlaceholder"),
            modes: [
                institute.supportsOnline ? .online : nil,
                institute.supportsHybrid ? .hybrid : nil,
                institute.supportsOffline ? .offline : nil
            ].compactMap { $0 }
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bannerCollectionView {
            return CGSize(width: bannerCardWidth(for: collectionView), height: 170)
        }

        return CGSize(width: 200, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == bannerCollectionView {
            return bannerSpacing(for: collectionView)
        }

        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == bannerCollectionView {
            return bannerSectionInsets(for: collectionView)
        }

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == nearByInstituteCollectionView else { return }

        let institute = nearbyInstitutes[indexPath.item]
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let instituteDetailsViewController = storyboard.instantiateViewController(
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
        instituteDetailsViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(instituteDetailsViewController, animated: true)
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

        let pageWidth = bannerScrollStep(for: bannerCollectionView)
        guard pageWidth > 0 else { return }
        guard totalBannerItemCount > 0 else { return }

        let adjustedOffset = targetContentOffset.pointee.x + bannerSectionInsets(for: bannerCollectionView).left
        let index = max(0, min(Int(round(adjustedOffset / pageWidth)), totalBannerItemCount - 1))
        let normalizedIndex = normalizedBannerIndex(for: index)
        targetContentOffset.pointee.x = CGFloat(normalizedIndex) * pageWidth - bannerSectionInsets(for: bannerCollectionView).left
        currentBannerIndex = normalizedIndex
    }
}

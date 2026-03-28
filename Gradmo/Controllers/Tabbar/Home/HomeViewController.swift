//
//  HomeViewController.swift
//  Gradmo
//
//  Created by Philanderer on 14/03/26.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {

    @IBOutlet weak var bannerCollectionView: UICollectionView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var studentView: UIView!
    
    @IBOutlet weak var totalEnrollmentInBatchesCountLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var nearByInstituteCollectionView: UICollectionView!

    private let bannerItems: [UIImage?] = [
        UIImage(named: "institutePlaceholder"),
        UIImage(named: "bannerPlaceholder"),
        UIImage(named: "bannerPlaceholder")
    ]

    private var bannerAutoScrollTimer: Timer?
    private var currentBannerIndex = 0
    private var blurOverlayView: UIControl?
    private var sideMenuContainerView: UIView?
    private var sideMenuLeadingConstraint: NSLayoutConstraint?
    private var sideMenuWidthConstraint: NSLayoutConstraint?
    private var sideMenuBottomConstraint: NSLayoutConstraint?
    private var overlayBottomConstraint: NSLayoutConstraint?
    private var sideMenuViewController: SideMenuViewController?
    private var isSideMenuVisible = false

    private let nearbyInstitutes: [NearbyInstitute] = [
        NearbyInstitute(
            name: "Apex Commerce Academy",
            address: "Salt Lake, KolkataSalt Lake, KolkataSalt Lake, KolkataSalt Lake, KolkataSalt Lake, Kolkata",
            rating: 4.8,
            image: UIImage(named: "institutePlaceholder"),
            modes: [.online, .offline]
        ),
        NearbyInstitute(
            name: "Future Minds Institute",
            address: "Park Street, Kolkata",
            rating: 4.6,
            image: UIImage(named: "institutePlaceholder"),
            modes: [.hybrid, .offline]
        ),
        NearbyInstitute(
            name: "Scholars Point",
            address: "New Town, Kolkata",
            rating: 4.9,
            image: UIImage(named: "institutePlaceholder"),
            modes: [.online, .hybrid, .offline]
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        startBannerAutoScroll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
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
    }
    
    @IBAction func sideMenuButtonTapped(_ sender: UIButton!){
        showSideMenu()
    }
    
    @IBAction func seeAllButtonTapped(_ sender: UIButton!){
        
    }
    
}

extension HomeViewController{
    private struct NearbyInstitute {
        let name: String
        let address: String
        let rating: Double
        let image: UIImage?
        let modes: [InstituteMode]
    }

    func setupView() {
        let fullName = UserCache.fullName()
        userNameLabel.text = fullName.isEmpty ? "Hi" : "Hi, \(fullName)"
        totalEnrollmentInBatchesCountLabel.text = "You’re enrolled in 3 active batches"
        searchTextField.placeholder = "Search an institute to enroll"
        searchTextField.setLeftPaddingPoints(40)
        searchTextField.setRightPaddingPoints(15)
        searchTextField.layer.cornerRadius = self.searchTextField.frame.height / 2
        searchTextField.layer.masksToBounds = true
        profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.height / 2
        profilePicImageView.clipsToBounds = true
        seeAllButton.setTitle("See all", for: .normal)

        if let imageURL = URL(string: UserCache.profileImageURL()), !UserCache.profileImageURL().isEmpty {
            profilePicImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "profilePic"))
        } else {
            profilePicImageView.image = UIImage(named: "profilePic")
        }
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
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bannerCollectionView {
            return bannerItems.count
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

            cell.configure(image: bannerItems[indexPath.item])
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
            address: institute.address,
            rating: institute.rating,
            image: institute.image,
            modes: institute.modes
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
            return 0
        }

        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == bannerCollectionView {
            return .zero
        }

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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

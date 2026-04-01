//
//  SearchInstituteViewController.swift
//  Gradmo
//
//  Created by Philanderer on 29/03/26.
//

import UIKit

final class SearchInstituteViewController: UIViewController {

    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var bannerCollectionView: UICollectionView!
    @IBOutlet private weak var resultsLabel: UILabel!
    @IBOutlet private weak var instituteTableView: UITableView!

    private let bannerItems: [UIImage?] = [
        UIImage(named: "institutePlaceholder"),
        UIImage(named: "bannerPlaceholder"),
        UIImage(named: "bannerPlaceholder")
    ]

    private let institutes: [InstituteItem] = [
        InstituteItem(
            name: "Apex Commerce Academy",
            address: "Salt Lake, Kolkata",
            rating: "4.8",
            instituteID: "ID: 0234",
            image: UIImage(named: "institutePlaceholder"),
            showsOnline: true,
            showsOffline: true,
            showsHybrid: false
        ),
        InstituteItem(
            name: "Future Minds Institute",
            address: "Park Street, Kolkata",
            rating: "4.6",
            instituteID: "ID: 0418",
            image: UIImage(named: "bannerPlaceholder"),
            showsOnline: false,
            showsOffline: true,
            showsHybrid: true
        ),
        InstituteItem(
            name: "Scholars Point",
            address: "New Town, Kolkata",
            rating: "4.9",
            instituteID: "ID: 0562",
            image: UIImage(named: "institutePlaceholder"),
            showsOnline: true,
            showsOffline: true,
            showsHybrid: true
        ),
        InstituteItem(
            name: "Bright Future Classes",
            address: "Howrah, Kolkata",
            rating: "4.7",
            instituteID: "ID: 0675",
            image: UIImage(named: "bannerPlaceholder"),
            showsOnline: true,
            showsOffline: false,
            showsHybrid: false
        )
    ]

    private var bannerAutoScrollTimer: Timer?
    private var currentBannerIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTableView()
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
    }
}

private extension SearchInstituteViewController {
    struct InstituteItem {
        let name: String
        let address: String
        let rating: String
        let instituteID: String
        let image: UIImage?
        let showsOnline: Bool
        let showsOffline: Bool
        let showsHybrid: Bool
    }

    func setupUI() {
        searchTextField.setLeftPaddingPoints(40)
        searchTextField.setRightPaddingPoints(15)
        searchTextField.layer.masksToBounds = true
        searchTextField.delegate = self

        resultsLabel.text = "Showing \(institutes.count) of \(institutes.count) results"
        instituteTableView.backgroundColor = .clear
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
        present(vc, animated: true)
    }
}

extension SearchInstituteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SearchInstituteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        institutes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: SearchInstituteTableViewCell.self),
            for: indexPath
        ) as? SearchInstituteTableViewCell else {
            return UITableViewCell()
        }

        let institute = institutes[indexPath.row]
        cell.configure(
            name: institute.name,
            address: institute.address,
            rating: institute.rating,
            instituteID: institute.instituteID,
            image: institute.image,
            showsOnline: institute.showsOnline,
            showsOffline: institute.showsOffline,
            showsHybrid: institute.showsHybrid
        )
        return cell
    }
}

extension SearchInstituteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bannerItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: BannerCollectionViewCell.self),
            for: indexPath
        ) as? BannerCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(image: bannerItems[indexPath.item])
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

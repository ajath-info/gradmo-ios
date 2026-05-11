//
//  InstituteDetailsViewController.swift
//  Gradmo
//
//  Created by Philanderer on 11/04/26.
//

import UIKit
import SDWebImage

class InstituteDetailsViewController: UIViewController {
     struct BatchItem {
        let batchID: Int
        let name: String
        let teacherName: String
        let timing: String
        let image: UIImage?
        let imageURL: String?
        let batchPriceText: String?
        let batchOfferPriceText: String?
    }

    private let batchCellReuseIdentifier = String(describing: MyBatchesTableViewCell.self)
    private let reviewCellReuseIdentifier = String(describing: RatingAndReviewTableViewCell.self)

    var batchItems: [BatchItem] = []
    var ratingItems: [RatingAndReviewItem] = []

    var selectedInstituteID: Int?
    var instituteNameText: String?
    var instituteMobileNumberText: String?
    var instituteEmailText: String?
    var instituteAddressText: String?
    var instituteImage: UIImage?
    var instituteImageURLText: String?
    var instituteRatingText: String?

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var instituteDetailsView: UIView!
    @IBOutlet weak var instituteBigImageView: UIImageView!
    @IBOutlet weak var instituteNameLabel: UILabel!
    @IBOutlet weak var instituteMobileNumberLabel: UILabel!
    @IBOutlet weak var instituteEmailLabel: UILabel!
    @IBOutlet weak var instituteaddressLabel: UILabel!

    @IBOutlet weak var batchesHeadingLabel: UILabel!
    @IBOutlet weak var batchesTableView: UITableView!
    @IBOutlet weak var ratingAndReviewHeadingLabel: UILabel!
    @IBOutlet weak var ratingAndReviewTableView: UITableView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var writeReviewButton: UIButton!

    @IBOutlet weak var batchView: UIView!
    @IBOutlet weak var noBatchAvailableView: UIView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var noRatingAvailableView: UIView!
    private var instituteDetailsTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViews()
        fetchInstituteDetailsIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        instituteDetailsView.layer.shadowPath = UIBezierPath(
            roundedRect: instituteDetailsView.bounds,
            cornerRadius: instituteDetailsView.layer.cornerRadius
        ).cgPath
    }

    deinit {
        instituteDetailsTask?.cancel()
    }

    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }

    @IBAction func batchesSeeAllButtonTapped(_ sender: UIButton!){
        guard !batchItems.isEmpty else {
            showToastSafely("No batches found")
            return
        }

        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let batchViewController = storyboard.instantiateViewController(
            withIdentifier: "BatchViewController"
        ) as? BatchViewController else {
            return
        }

        batchViewController.batchItems = batchItems
        batchViewController.headerTitleText = "Batch"
        batchViewController.instituteNameText = instituteNameText ?? instituteNameLabel.text
        batchViewController.instituteRatingText = instituteRatingText ?? ratingLabel.text
        batchViewController.instituteImage = instituteImage
        batchViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(batchViewController, animated: true)
    }

    @IBAction func ratingAndReviewSeeAllButtonTapped(_ sender: UIButton!){

    }

    @IBAction func writeReviewButtonTapped(_ sender: UIButton!) {
        guard let ratingAndReviewViewController = storyboard?.instantiateViewController(
            withIdentifier: "RatingAndReviewViewController"
        ) as? RatingAndReviewViewController else {
            return
        }

        navigationController?.pushViewController(ratingAndReviewViewController, animated: true)
    }

}

extension InstituteDetailsViewController{
    func fetchInstituteDetailsIfNeeded() {
        guard let selectedInstituteID else {
            updateSectionVisibility()
            return
        }

        instituteDetailsTask?.cancel()
        instituteDetailsTask = Task { [weak self] in
            do {
                let response = try await InstituteDetailsService.fetchInstituteDetails(instituteID: selectedInstituteID)

                await MainActor.run {
                    guard let self else { return }
                    let status = response.status.lowercased()
                    guard status == "true" || status == "1" || status == "success" else {
                        self.showToastSafely(response.msg ?? "Unable to fetch institute details")
                        return
                    }

                    self.applyInstituteDetails(response)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showToastSafely((error as? LocalizedError)?.errorDescription ?? "Unable to fetch institute details")
                    self?.updateSectionVisibility()
                }
            }
        }
    }

    func applyInstituteDetails(_ response: InstituteDetailsResponse) {
        if let institute = response.institute {
            instituteNameText = sanitized(institute.name) ?? instituteNameText
            instituteMobileNumberText = sanitized(institute.mobile) ?? instituteMobileNumberText
            instituteEmailText = sanitized(institute.email) ?? instituteEmailText
            instituteImageURLText = sanitized(institute.imageURL) ?? sanitized(institute.image) ?? instituteImageURLText

            instituteNameLabel.text = instituteNameText ?? "Institute"
            instituteMobileNumberLabel.text = instituteMobileNumberText ?? "Not available"
            instituteEmailLabel.text = instituteEmailText ?? "Not available"

            if let instituteImageURLText,
               !instituteImageURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = URL(string: instituteImageURLText) {
                instituteBigImageView.sd_setImage(with: url, placeholderImage: instituteImage ?? UIImage(named: "institutePlaceholder"))
            }
        }

        if let rating = response.rating {
            let averageRating = rating.averageRating ?? 0
            let totalReviews = rating.totalReviews ?? response.reviews.count
            instituteRatingText = String(format: "%.1f(%d)", averageRating, totalReviews)
            ratingLabel.text = instituteRatingText
        }

        batchItems = response.batches.compactMap { batch in
            guard let batchID = batch.id else { return nil }
            return BatchItem(
                batchID: batchID,
                name: sanitized(batch.batchName) ?? "Batch",
                teacherName: sanitized(batch.batchMode) ?? "Not available",
                timing: batch.displayTiming,
                image: UIImage(named: "institutePlaceholder"),
                imageURL: batch.displayImageURL,
                batchPriceText: sanitized(batch.batchPrice),
                batchOfferPriceText: sanitized(batch.batchOfferPrice)
            )
        }

        ratingItems = response.reviews.map { review in
            RatingAndReviewItem(
                userName: review.userType?.capitalized ?? "Student",
                ratingText: String(format: "%.1f Rating", review.rating ?? 0),
                reviewDate: review.displayCreatedAt,
                reviewText: sanitized(review.msg) ?? "",
                userImage: UIImage(named: "profilePic")
            )
        }

        batchesTableView.reloadData()
        ratingAndReviewTableView.reloadData()
        updateSectionVisibility()
    }

    func setupUI(){
        view.backgroundColor = .white
        headerLabel.font = UIFont.GilroySemiBold(ofSize: 17)
        headerLabel.textColor = Colors.baseColorBlack ?? .label

        writeReviewButton.layer.cornerRadius = self.writeReviewButton.frame.height / 2

        instituteBigImageView.layer.cornerRadius = 0
        instituteBigImageView.clipsToBounds = true
        instituteBigImageView.contentMode = .scaleAspectFill

        instituteDetailsView.layer.cornerRadius = 20
        instituteDetailsView.layer.masksToBounds = false
        instituteDetailsView.layer.shadowColor = UIColor.black.cgColor
        instituteDetailsView.layer.shadowOpacity = 0.12
        instituteDetailsView.layer.shadowOffset = CGSize(width: 0, height: 8)
        instituteDetailsView.layer.shadowRadius = 16

        instituteNameLabel.font = UIFont.GilroyBold(ofSize: 14)
        instituteMobileNumberLabel.font = UIFont.GilroyMedium(ofSize: 12)
        instituteEmailLabel.font = UIFont.GilroyMedium(ofSize: 12)
        instituteaddressLabel.font = UIFont.GilroyMedium(ofSize: 12)
        batchesHeadingLabel.font = UIFont.GilroySemiBold(ofSize: 14)
        ratingAndReviewHeadingLabel.font = UIFont.GilroySemiBold(ofSize: 14)

        instituteNameLabel.text = instituteNameText ?? "Upgrade Classes"
        instituteMobileNumberLabel.text = instituteMobileNumberText ?? "+91 98765 43210"
        instituteEmailLabel.text = instituteEmailText ?? "upgradeclasses@gmail.com"
        instituteaddressLabel.text = instituteAddressText ?? "C-12, Pandara Road, Connaught Place, New Delhi - 110001"
        ratingLabel.text = instituteRatingText ?? "4.5(201)"
        if let instituteImageURLText,
           !instituteImageURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let url = URL(string: instituteImageURLText) {
            instituteBigImageView.sd_setImage(with: url, placeholderImage: instituteImage ?? UIImage(named: "institutePlaceholder"))
        } else {
            instituteBigImageView.image = instituteImage ?? UIImage(named: "institutePlaceholder")
        }
        updateSectionVisibility()
    }

    func setupTableViews() {
        batchesTableView.delegate = self
        batchesTableView.dataSource = self
        batchesTableView.registerXib(MyBatchesTableViewCell.self)
        batchesTableView.separatorStyle = .none
        batchesTableView.backgroundColor = .clear
        batchesTableView.showsVerticalScrollIndicator = false
        batchesTableView.rowHeight = 102
        batchesTableView.estimatedRowHeight = 102

        ratingAndReviewTableView.delegate = self
        ratingAndReviewTableView.dataSource = self
        ratingAndReviewTableView.registerXib(RatingAndReviewTableViewCell.self)
        ratingAndReviewTableView.separatorStyle = .none
        ratingAndReviewTableView.backgroundColor = .clear
        ratingAndReviewTableView.showsVerticalScrollIndicator = false
        ratingAndReviewTableView.rowHeight = 89
        ratingAndReviewTableView.estimatedRowHeight = 89

        batchesTableView.reloadData()
        ratingAndReviewTableView.reloadData()
        updateSectionVisibility()
    }

    func updateSectionVisibility() {
        let hasBatches = !batchItems.isEmpty
        let hasRatings = !ratingItems.isEmpty

        batchView.isHidden = false
        ratingView.isHidden = false
        batchesTableView.isHidden = !hasBatches
        ratingAndReviewTableView.isHidden = !hasRatings
        noBatchAvailableView.isHidden = hasBatches
        noRatingAvailableView.isHidden = hasRatings
    }

    func sanitized(_ value: String?) -> String? {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    func openBatchDetails(for item: BatchItem) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let batchDetailViewController = storyboard.instantiateViewController(
            withIdentifier: "BatchDetailViewController"
        ) as? BatchDetailViewController else {
            return
        }

        batchDetailViewController.selectedBatchID = item.batchID
        batchDetailViewController.batchDetail = .init(
            batchID: item.batchID,
            instituteName: instituteNameText ?? instituteNameLabel.text ?? "Institute",
            batchName: item.name,
            teacherName: item.teacherName,
            time: item.timing,
            rating: instituteRatingText ?? "4.8",
            subject: "Commerce",
            grade: "Grade 12",
            image: item.image ?? instituteImage,
            imageURL: item.imageURL,
            batchPriceText: item.batchPriceText,
            batchOfferPriceText: item.batchOfferPriceText
        )
        batchDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(batchDetailViewController, animated: true)
    }
}

extension InstituteDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == batchesTableView {
            return batchItems.count
        }

        return ratingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == batchesTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: batchCellReuseIdentifier,
                for: indexPath
            ) as? MyBatchesTableViewCell else {
                return UITableViewCell()
            }

            let item = batchItems[indexPath.row]
            cell.configure(
                batchName: item.name,
                teacherName: item.teacherName,
                timing: item.timing,
                image: item.image,
                imageURL: item.imageURL
            )
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reviewCellReuseIdentifier,
            for: indexPath
        ) as? RatingAndReviewTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: ratingItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard tableView == batchesTableView else {
            return
        }

        openBatchDetails(for: batchItems[indexPath.row])
    }
}

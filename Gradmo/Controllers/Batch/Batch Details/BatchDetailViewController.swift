//
//  BatchDetailViewController.swift
//  Gradmo
//
//  Created by Philanderer on 05/04/26.
//

import UIKit

struct BatchDetailItem {
    let batchID: Int?
    let instituteName: String
    let batchName: String
    let teacherName: String
    let time: String
    let rating: String
    let subject: String
    let grade: String
    let image: UIImage?
    let imageURL: String?
    let batchPriceText: String?
    let batchOfferPriceText: String?
}

struct BatchDetailOptionItem {
    let title: String
    let image: UIImage?
}

class BatchDetailViewController: UIViewController {
    @IBOutlet weak var batchNameCollectionView: UICollectionView!
    @IBOutlet weak var batchDetailOptionCollectionView: UICollectionView!
    @IBOutlet weak var glassView: UIView!
    @IBOutlet weak var enrollButton: UIButton!

    var batchDetail: BatchDetailItem?
    var selectedBatchID: Int?
    private var hasEnrolled = false
    private var isLiveClassActive = false
    private var currentLiveClassSessionID: String?
    private var batchDetailsTask: Task<Void, Never>?
    private let batchDetailOptions: [BatchDetailOptionItem] = [
        BatchDetailOptionItem(title: "Live classes", image: UIImage(named: "liveClasses")),
        BatchDetailOptionItem(title: "Video Lectures", image: UIImage(named: "videoLectures")),
        BatchDetailOptionItem(title: "Library", image: UIImage(named: "library")),
        BatchDetailOptionItem(title: "Attendance", image: UIImage(named: "attendance")),
        BatchDetailOptionItem(title: "Upcoming Exams", image: UIImage(named: "upcomingExams")),
        BatchDetailOptionItem(title: "Homework", image: UIImage(named: "homework"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enrollButton.layer.cornerRadius = 12
        enrollButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)
        setupCollectionView()
        applyEnrollmentState()
        fetchBatchDetailsIfNeeded()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func enrollButtonTapped(_ sender: UIButton!){
        openPaymentPlan()
    }

    deinit {
        batchDetailsTask?.cancel()
    }

}

private extension BatchDetailViewController {
    func fetchBatchDetailsIfNeeded() {
        let batchID = selectedBatchID ?? batchDetail?.batchID
        guard let batchID else { return }

        batchDetailsTask?.cancel()
        batchDetailsTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await BatchDetailsService.fetchBatchDetails(batchID: batchID)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    if let details = response.batchDetails {
                        self.applyBatchDetails(details)
                    } else {
                        self.showToastSafely(response.msg ?? response.message ?? "Unable to fetch batch details")
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.showToastSafely((error as? LocalizedError)?.errorDescription ?? "Unable to fetch batch details")
                }
            }
        }
    }

    func applyBatchDetails(_ details: BatchDetailsItem) {
        let currentInstituteName = batchDetail?.instituteName ?? "Institute"
        let currentImage = batchDetail?.image
        let currentImageURL = batchDetail?.imageURL

        batchDetail = BatchDetailItem(
            batchID: details.batchID,
            instituteName: currentInstituteName,
            batchName: sanitized(details.batchName) ?? sanitized(details.title) ?? batchDetail?.batchName ?? "Batch",
            teacherName: sanitized(details.instructor) ?? batchDetail?.teacherName ?? "Not available",
            time: sanitized(details.displayTiming) ?? batchDetail?.time ?? "Not available",
            rating: sanitized(details.payMode) ?? batchDetail?.rating ?? "N/A",
            subject: sanitized(details.categoryName) ?? batchDetail?.subject ?? "N/A",
            grade: sanitized(details.subcategoryName) ?? batchDetail?.grade ?? "N/A",
            image: currentImage,
            imageURL: sanitized(details.batchImage) ?? sanitized(details.logo) ?? currentImageURL,
            batchPriceText: sanitized(details.batchPrice) ?? batchDetail?.batchPriceText,
            batchOfferPriceText: sanitized(details.batchOfferPrice) ?? batchDetail?.batchOfferPriceText
        )

        selectedBatchID = details.batchID
        hasEnrolled = (details.enrollment?.status ?? 0) == 1
        isLiveClassActive = details.modules?.liveClasses?.isLive == true
        currentLiveClassSessionID = sanitized(details.modules?.liveClasses?.currentSessionID)
        applyEnrollmentState()
        batchNameCollectionView.reloadData()
        batchDetailOptionCollectionView.reloadData()
    }

    func applyEnrollmentState() {
        glassView.isHidden = hasEnrolled
        enrollButton.isHidden = hasEnrolled
        batchDetailOptionCollectionView.reloadData()
    }

    func sanitized(_ value: String?) -> String? {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    func setupCollectionView() {
        batchNameCollectionView.delegate = self
        batchNameCollectionView.dataSource = self
        batchNameCollectionView.registerXib(BatchDetailsCollectionViewCell.self)
        batchNameCollectionView.showsHorizontalScrollIndicator = false
        batchNameCollectionView.showsVerticalScrollIndicator = false
        batchNameCollectionView.isScrollEnabled = false
        batchNameCollectionView.backgroundColor = .clear

        batchDetailOptionCollectionView.delegate = self
        batchDetailOptionCollectionView.dataSource = self
        batchDetailOptionCollectionView.registerXib(BatchDetailsOptionsCollectionViewCell.self)
        batchDetailOptionCollectionView.showsHorizontalScrollIndicator = false
        batchDetailOptionCollectionView.showsVerticalScrollIndicator = false
        batchDetailOptionCollectionView.isScrollEnabled = true
        batchDetailOptionCollectionView.backgroundColor = .clear
    }

    func openLibraryScreen(for mode: LibraryViewController.ScreenMode) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let libraryViewController = storyboard.instantiateViewController(
            withIdentifier: "LibraryViewController"
        ) as? LibraryViewController else {
            return
        }

        libraryViewController.comingFrom = mode.rawValue
        libraryViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(libraryViewController, animated: true)
    }

    func openUpcomingExamScreen() {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let upcomingExamViewController = storyboard.instantiateViewController(
            withIdentifier: "UpcomingExamViewController"
        ) as? UpcomingExamViewController else {
            return
        }

        upcomingExamViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(upcomingExamViewController, animated: true)
    }

    func openHomeworkScreen() {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let homeworkViewController = storyboard.instantiateViewController(
            withIdentifier: "HomeworkViewController"
        ) as? HomeworkViewController else {
            return
        }

        homeworkViewController.batchID = selectedBatchID ?? batchDetail?.batchID
        homeworkViewController.batchName = batchDetail?.batchName
        homeworkViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(homeworkViewController, animated: true)
    }

    func openAttendanceScreen() {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let attendanceViewController = storyboard.instantiateViewController(
            withIdentifier: "AttendanceViewController"
        ) as? AttendanceViewController else {
            return
        }

        attendanceViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(attendanceViewController, animated: true)
    }

    func openTeacherAttendanceScreen() {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let teacherAttendanceViewController = storyboard.instantiateViewController(
            withIdentifier: "TeacherAttendanceViewController"
        ) as? TeacherAttendanceViewController else {
            return
        }

        teacherAttendanceViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(teacherAttendanceViewController, animated: true)
    }

    func openLiveClass() {
        ZoomManager.shared.openLiveClass(from: self, joinURLString: currentLiveClassSessionID)
    }

    func openTeacherLiveClassScreen() {
        let teacherLiveClassViewController = TeacherLiveClassViewController()
        teacherLiveClassViewController.batchID = selectedBatchID ?? batchDetail?.batchID
        teacherLiveClassViewController.batchName = batchDetail?.batchName
        teacherLiveClassViewController.existingSessionID = currentLiveClassSessionID
        teacherLiveClassViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(teacherLiveClassViewController, animated: true)
    }

    func openPaymentPlan() {
        guard let batchDetail else {
            showToastSafely("Batch details are still loading")
            return
        }

        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let paymentPlanViewController = storyboard.instantiateViewController(
            withIdentifier: "PaymentPlanViewController"
        ) as? PaymentPlanViewController else {
            return
        }

        paymentPlanViewController.paymentContext = PaymentCheckoutContext.make(
            batchID: selectedBatchID ?? batchDetail.batchID,
            instituteName: batchDetail.instituteName,
            batchName: batchDetail.batchName,
            batchPriceText: batchDetail.batchPriceText,
            batchOfferPriceText: batchDetail.batchOfferPriceText
        )
        paymentPlanViewController.onPaymentSuccess = { [weak self] in
            self?.hasEnrolled = true
            self?.applyEnrollmentState()
        }
        paymentPlanViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(paymentPlanViewController, animated: true)
    }

}

extension BatchDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == batchNameCollectionView {
            return batchDetail == nil ? 0 : 1
        }

        return batchDetailOptions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == batchNameCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: BatchDetailsCollectionViewCell.self),
                for: indexPath
            ) as? BatchDetailsCollectionViewCell,
                  let batchDetail else {
                return UICollectionViewCell()
            }

            cell.configure(
                instituteName: batchDetail.instituteName,
                batchName: batchDetail.batchName,
                teacherName: batchDetail.teacherName,
                time: batchDetail.time,
                rating: batchDetail.rating,
                subject: batchDetail.subject,
                grade: batchDetail.grade,
                image: batchDetail.image,
                imageURL: batchDetail.imageURL
            )
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: BatchDetailsOptionsCollectionViewCell.self),
            for: indexPath
        ) as? BatchDetailsOptionsCollectionViewCell else {
            return UICollectionViewCell()
        }

        let option = batchDetailOptions[indexPath.item]
        cell.configure(
            title: option.title,
            image: option.image,
            showsIndicator: option.title.caseInsensitiveCompare("Live classes") == .orderedSame && isLiveClassActive
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == batchNameCollectionView {
            return CGSize(width: collectionView.bounds.width, height: 180)
        }

        let spacing: CGFloat = 10
        let horizontalInset: CGFloat = 20
        let totalSpacing = horizontalInset + spacing
        let width = floor((collectionView.bounds.width - totalSpacing) / 2)
        let rowStartIndex = (indexPath.item / 2) * 2
        let rowEndIndex = min(rowStartIndex + 2, batchDetailOptions.count)
        let rowOptions = batchDetailOptions[rowStartIndex..<rowEndIndex]
        let labelWidth = max(0, width - 24)
        let maxLabelHeight = rowOptions.reduce(CGFloat.zero) { currentMax, option in
            let labelHeight = option.title.boundingRect(
                with: CGSize(width: labelWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: UIFont.GilroyBold(ofSize: 16)],
                context: nil
            ).height
            return max(currentMax, ceil(labelHeight))
        }
        let height = ceil(20 + 100 + 8 + maxLabelHeight + 28)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionView == batchNameCollectionView ? 0 : 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        collectionView == batchNameCollectionView ? 0 : 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionView == batchNameCollectionView ? .zero : .init(top: 0, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == batchDetailOptionCollectionView else {
            return
        }

        let option = batchDetailOptions[indexPath.item]

        switch option.title.lowercased() {
        case "live classes":
            if UserCache.getUserRole() == .teacher {
                openTeacherLiveClassScreen()
            } else {
                openLiveClass()
            }
        case "library":
            openLibraryScreen(for: .library)
        case "video lectures":
            openLibraryScreen(for: .video)
        case "attendance":
            if UserCache.getUserRole() == .teacher {
                openTeacherAttendanceScreen()
            } else {
                openAttendanceScreen()
            }
        case "upcoming exams":
            openUpcomingExamScreen()
        case "homework":
            openHomeworkScreen()
        default:
            break
        }
    }
}

//
//  BatchViewController.swift
//  Gradmo
//
//  Created by Philanderer on 18/04/26.
//

import UIKit
import SDWebImage

class BatchViewController: UIViewController {

    @IBOutlet weak var batchTableview: UITableView!
    @IBOutlet weak var headerLabel: UILabel!

    var batchItems: [InstituteDetailsViewController.BatchItem] = []
    var headerTitleText = "Batch"
    var shouldFetchEnrolledBatches = false
    var instituteNameText: String?
    var instituteRatingText: String?
    var instituteImage: UIImage?

    private let batchCellReuseIdentifier = String(describing: MyBatchesTableViewCell.self)
    private var batchListTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if shouldFetchEnrolledBatches {
            batchItems = []
        }
        setupTableView()
        fetchEnrolledBatchesIfNeeded()
    }

    deinit {
        batchListTask?.cancel()
    }

    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }

}

private extension BatchViewController {
    func setupUI() {
        headerLabel.text = headerTitleText
        headerLabel.font = UIFont.GilroySemiBold(ofSize: 17)
        headerLabel.textColor = Colors.baseColorBlack ?? .label
    }

    func setupTableView() {
        batchTableview.delegate = self
        batchTableview.dataSource = self
        batchTableview.registerXib(MyBatchesTableViewCell.self)
        batchTableview.separatorStyle = .none
        batchTableview.backgroundColor = .clear
        batchTableview.showsVerticalScrollIndicator = false
        batchTableview.rowHeight = 102
        batchTableview.estimatedRowHeight = 102
        batchTableview.reloadData()
    }

    func fetchEnrolledBatchesIfNeeded() {
        guard shouldFetchEnrolledBatches else { return }

        batchListTask?.cancel()
        batchListTask = Task { [weak self] in
            do {
                let response = try await BatchListService.fetchEnrolledBatches()
                let fetchedBatches = response.data?.enrolledBatches.map(Self.makeBatchItem(from:)) ?? []
                let displayBatches = await Self.batchesWithLoadedImages(fetchedBatches)

                await MainActor.run {
                    guard let self else { return }
                    let status = response.status.lowercased()
                    guard status == "true" || status == "1" || status == "success" else {
                        self.showToastSafely(response.message ?? response.msg ?? "Unable to fetch batches")
                        return
                    }

                    self.batchItems = displayBatches
                    self.batchTableview.reloadData()

                    if displayBatches.isEmpty {
                        self.showToastSafely(response.message ?? response.msg ?? "No batches found")
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showToastSafely(Self.errorMessage(from: error))
                }
            }
        }
    }

    static func makeBatchItem(from item: EnrolledBatchItem) -> InstituteDetailsViewController.BatchItem {
        InstituteDetailsViewController.BatchItem(
            batchID: item.batchID,
            name: nonEmpty(item.batchName) ?? nonEmpty(item.title) ?? "Batch",
            teacherName: nonEmpty(item.instructor) ?? "Not available",
            timing: item.displayTiming,
            image: UIImage(named: "institutePlaceholder"),
            imageURL: nonEmpty(item.batchImage) ?? nonEmpty(item.logo),
            batchPriceText: nil,
            batchOfferPriceText: nil
        )
    }

    static func batchesWithLoadedImages(_ items: [InstituteDetailsViewController.BatchItem]) async -> [InstituteDetailsViewController.BatchItem] {
        var displayItems: [InstituteDetailsViewController.BatchItem] = []

        for item in items {
            let loadedImage = await loadImage(from: item.imageURL)
            displayItems.append(
                InstituteDetailsViewController.BatchItem(
                    batchID: item.batchID,
                    name: item.name,
                    teacherName: item.teacherName,
                    timing: item.timing,
                    image: loadedImage ?? item.image,
                    imageURL: item.imageURL,
                    batchPriceText: item.batchPriceText,
                    batchOfferPriceText: item.batchOfferPriceText
                )
            )
        }

        return displayItems
    }

    static func loadImage(from imageURL: String?) async -> UIImage? {
        guard let imageURL = nonEmpty(imageURL),
              let url = URL(string: imageURL) else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            SDWebImageManager.shared.loadImage(
                with: url,
                options: [.retryFailed, .highPriority],
                progress: nil
            ) { image, _, _, _, _, _ in
                continuation.resume(returning: image)
            }
        }
    }

    static func nonEmpty(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }

    static func errorMessage(from error: Error) -> String {
        switch error {
        case NetworkError.noInternetConnection:
            return "No internet connection"
        case NetworkError.apiError(let message),
             NetworkError.requestFailed(let message),
             NetworkError.decodingError(let message):
            return message
        case NetworkError.validation(let response):
            return response.error.first?.message ?? "Unable to fetch batches"
        default:
            return "Unable to fetch batches"
        }
    }

    func openBatchDetails(for item: InstituteDetailsViewController.BatchItem) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let batchDetailViewController = storyboard.instantiateViewController(
            withIdentifier: "BatchDetailViewController"
        ) as? BatchDetailViewController else {
            return
        }

        batchDetailViewController.selectedBatchID = item.batchID
        batchDetailViewController.batchDetail = .init(
            batchID: item.batchID,
            instituteName: instituteNameText ?? "Institute",
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

extension BatchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        batchItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openBatchDetails(for: batchItems[indexPath.row])
    }
}

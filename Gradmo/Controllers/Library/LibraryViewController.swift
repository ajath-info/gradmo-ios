//
//  LibraryViewController.swift
//  swift
//
//  Created by Rishabh   on 10/04/26.
//

import UIKit

private let libraryDisplayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy"
    return formatter
}()

struct LibraryItem {
    let title: String
    let size: String
    let dateAdded: String
    let sortDate: Date
    let imageName: String
}

struct VideoLectureItem {
    let title: String
    let duration: String
    let date: String
    let sortDate: Date
    let imageName: String
}

class LibraryViewController: UIViewController {
    enum ScreenMode: String {
        case video
        case library
    }
    
    enum SortOption: String {
        case newestFirst = "Newest First"
        case oldestFirst = "Oldest First"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }
    
    private var allLibraryItems: [LibraryItem] = []
    private var allVideoItems: [VideoLectureItem] = []
    
    private let collectionCellReuseIdentifier = "LibraryCollectionViewCell"
    private let videoCellReuseIdentifier = "VideoLecturesTableViewCell"
    private let itemsPerRow: CGFloat = 2
    private let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let itemSpacing: CGFloat = 10
    
    private var displayedLibraryItems: [LibraryItem] = []
    private var displayedVideoItems: [VideoLectureItem] = []
    private var selectedSortOption: SortOption = .newestFirst

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var sortByLabel: UILabel!
    @IBOutlet weak var sortByDropdownButton: UIButton!
    @IBOutlet weak var dropdownLabel: UILabel!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var videoLectureTableView: UITableView!
    
    var comingFrom: String = ScreenMode.library.rawValue
    
    private var screenMode: ScreenMode {
        ScreenMode(rawValue: comingFrom.lowercased()) ?? .library
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.setLeftPaddingPoints(40)
        searchTextField.borderStyle = .none
        searchTextField.clipsToBounds = true
        dropdownView.layer.borderColor = (Colors.baseColorGray ?? UIColor.systemGray4).cgColor
        dropdownView.layer.borderWidth = 1
        allLibraryItems = makeLibraryItems()
        allVideoItems = makeVideoItems()
        displayedLibraryItems = allLibraryItems
        displayedVideoItems = allVideoItems
        configureCollectionView()
        configureTableView()
        configureScreen()
        configureDropdownMenu()
        updateVisibleContent()
        applySort(option: selectedSortOption)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTextField.layer.cornerRadius = searchTextField.bounds.height / 2
        dropdownView.layer.cornerRadius = dropdownView.bounds.height / 2
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropdownButtonTapped(_ sender: UIButton) {
        sortByDropdownButton.showsMenuAsPrimaryAction = true
    }
}

private extension LibraryViewController {
    func configureScreen() {
        sortByLabel.text = "Sort By :"
        dropdownLabel.text = selectedSortOption.rawValue
        
        switch screenMode {
        case .library:
            headerLabel.text = "Library"
            searchTextField.placeholder = "Chapter"
        case .video:
            headerLabel.text = "Video Lectures"
            searchTextField.placeholder = "Video Lecture"
        }
    }
    
    func configureCollectionView() {
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        contentCollectionView.register(
            UINib(nibName: collectionCellReuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: collectionCellReuseIdentifier
        )
    }
    
    func configureTableView() {
        videoLectureTableView.delegate = self
        videoLectureTableView.dataSource = self
        videoLectureTableView.separatorStyle = .none

        videoLectureTableView.register(
            UINib(nibName: videoCellReuseIdentifier, bundle: nil),
            forCellReuseIdentifier: videoCellReuseIdentifier
        )
    }
    
    func configureDropdownMenu() {
        sortByDropdownButton.showsMenuAsPrimaryAction = true
        reloadDropdownMenu()
    }
    
    func reloadDropdownMenu() {
        let actions = [
            SortOption.newestFirst,
            SortOption.oldestFirst,
            SortOption.thisWeek,
            SortOption.thisMonth
        ].map { option in
            UIAction(
                title: option.rawValue,
                state: option == selectedSortOption ? .on : .off
            ) { [weak self] _ in
                self?.applySort(option: option)
            }
        }
        
        sortByDropdownButton.menu = UIMenu(title: "Sort By Date", children: actions)
    }
    
    func makeLibraryItems() -> [LibraryItem] {
        (1...10).map {
            let sortDate = Calendar.current.date(byAdding: .day, value: -($0 - 1) * 3, to: Date()) ?? Date()
            return LibraryItem(
                title: "Chapter \($0)",
                size: "\((($0 * 12) + 8)) MB",
                dateAdded: libraryDisplayDateFormatter.string(from: sortDate),
                sortDate: sortDate,
                imageName: "books.vertical.fill"
            )
        }
    }
    
    func makeVideoItems() -> [VideoLectureItem] {
        (1...10).map {
            let sortDate = Calendar.current.date(byAdding: .day, value: -($0 - 1) * 2, to: Date()) ?? Date()
            return VideoLectureItem(
                title: "Video Lecture \($0)",
                duration: "\(20 + $0) min",
                date: libraryDisplayDateFormatter.string(from: sortDate),
                sortDate: sortDate,
                imageName: "play.rectangle.fill"
            )
        }
    }
    
    func applySort(option: SortOption) {
        selectedSortOption = option
        dropdownLabel.text = option.rawValue
        
        switch option {
        case .newestFirst:
            displayedLibraryItems = allLibraryItems.sorted { $0.sortDate > $1.sortDate }
            displayedVideoItems = allVideoItems.sorted { $0.sortDate > $1.sortDate }
        case .oldestFirst:
            displayedLibraryItems = allLibraryItems.sorted { $0.sortDate < $1.sortDate }
            displayedVideoItems = allVideoItems.sorted { $0.sortDate < $1.sortDate }
        case .thisWeek:
            displayedLibraryItems = filteredItemsWithinLast(days: 7, from: allLibraryItems)
            displayedVideoItems = filteredItemsWithinLast(days: 7, from: allVideoItems)
        case .thisMonth:
            displayedLibraryItems = filteredItemsWithinLast(days: 30, from: allLibraryItems)
            displayedVideoItems = filteredItemsWithinLast(days: 30, from: allVideoItems)
        }
        
        reloadDropdownMenu()
        contentCollectionView.reloadData()
        videoLectureTableView.reloadData()
    }
    
    func filteredItemsWithinLast(days: Int, from items: [LibraryItem]) -> [LibraryItem] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date.distantPast
        return items
            .filter { $0.sortDate >= cutoffDate }
            .sorted { $0.sortDate > $1.sortDate }
    }
    
    func filteredItemsWithinLast(days: Int, from items: [VideoLectureItem]) -> [VideoLectureItem] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date.distantPast
        return items
            .filter { $0.sortDate >= cutoffDate }
            .sorted { $0.sortDate > $1.sortDate }
    }
    
    func updateVisibleContent() {
        let isLibraryMode = screenMode == .library
        contentCollectionView.isHidden = !isLibraryMode
        videoLectureTableView.isHidden = isLibraryMode
    }

    func openVideoLectureDetail(for item: VideoLectureItem) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let videoLectureViewController = storyboard.instantiateViewController(
            withIdentifier: "VideoLectureViewController"
        ) as? VideoLectureViewController else {
            return
        }

        videoLectureViewController.lectureContent = VideoLectureContent(
            thumbnailImage: UIImage(named: "videoLectures"),
            title: item.title,
            dateText: "Uploaded on \(item.date)",
            durationText: item.duration,
            classTagText: "Class 12th",
            contextTagText: "Recorded",
            descriptionText: "This recorded lecture is available for quick revision inside your batch. Open it anytime to revisit the full topic flow, pause at important moments, and continue learning at your own pace."
        )
        videoLectureViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(videoLectureViewController, animated: true)
    }
}

extension LibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedLibraryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: collectionCellReuseIdentifier,
            for: indexPath
        ) as? LibraryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: displayedLibraryItems[indexPath.item])
        return cell
    }
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalHorizontalPadding = sectionInset.left + sectionInset.right + itemSpacing
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let cellWidth = floor(availableWidth / itemsPerRow)
        
        return CGSize(width: cellWidth, height: 220)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        itemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        itemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        sectionInset
    }
}

extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedVideoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: videoCellReuseIdentifier,
            for: indexPath
        ) as? VideoLecturesTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: displayedVideoItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard screenMode == .video else { return }
        openVideoLectureDetail(for: displayedVideoItems[indexPath.row])
    }
}

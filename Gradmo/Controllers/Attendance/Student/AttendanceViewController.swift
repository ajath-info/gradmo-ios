//
//  AttendanceViewController.swift
//  Gradmo
//
//  Created by Codex on 06/05/26.
//

import UIKit

private enum AttendanceStatus {
    case present
    case halfDay
    case absent
    case none

    var fillColor: UIColor {
        switch self {
        case .present:
            return UIColor(hex: "#23B92D")
        case .halfDay:
            return UIColor(hex: "#F2E500")
        case .absent:
            return UIColor(hex: "#D95832")
        case .none:
            return .clear
        }
    }

    var usesLightText: Bool {
        switch self {
        case .present, .absent:
            return true
        case .halfDay, .none:
            return false
        }
    }
}

private struct AttendanceCalendarDay {
    let day: Int?
    let status: AttendanceStatus
    let isCurrentMonth: Bool
}

final class AttendanceViewController: UIViewController {

    private let calendar = Calendar.current
    private var visibleMonth: Date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1)) ?? Date()
    private var days: [AttendanceCalendarDay] = []

    private let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]
    private var attendanceByMonth: [String: [Int: AttendanceStatus]] = [
        "2026-03": [
            1: .present,
            2: .present,
            3: .present,
            4: .present,
            5: .present,
            6: .present,
            7: .present,
            8: .present,
            9: .present,
            10: .present,
            11: .present,
            12: .absent,
            13: .present,
            14: .present,
            15: .present,
            16: .absent,
            17: .halfDay,
            18: .present,
            19: .present,
            20: .halfDay,
            21: .present,
            22: .present,
            23: .present,
            24: .absent,
            25: .present
        ]
    ]

    private let titleLabel = UILabel()
    private let monthLabel = UILabel()
    private let collectionView: UICollectionView
    private let summaryLabel = UILabel()

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupViews()
        reloadMonth()
    }
}

private extension AttendanceViewController {

    func setupViews() {
        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = Colors.baseColorBlack ?? UIColor(hex: "#2B2B2B")
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Attendance"
        titleLabel.textAlignment = .center
        titleLabel.textColor = Colors.baseColorBlack ?? UIColor(hex: "#2B2B2B")
        titleLabel.font = UIFont.GilroyBold(ofSize: 17)

        let previousButton = monthNavigationButton(imageName: "arrow.left")
        previousButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)

        let nextButton = monthNavigationButton(imageName: "arrow.right")
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)

        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.textAlignment = .center
        monthLabel.textColor = Colors.themeColor ?? UIColor(hex: "#3B7BFF")
        monthLabel.font = UIFont.GilroyBold(ofSize: 22)

        let monthStackView = UIStackView(arrangedSubviews: [previousButton, monthLabel, nextButton])
        monthStackView.translatesAutoresizingMaskIntoConstraints = false
        monthStackView.axis = .horizontal
        monthStackView.alignment = .center
        monthStackView.distribution = .equalCentering

        let weekdayStackView = UIStackView()
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        weekdayStackView.axis = .horizontal
        weekdayStackView.distribution = .fillEqually

        weekdaySymbols.forEach { symbol in
            let label = UILabel()
            label.text = symbol
            label.textAlignment = .center
            label.textColor = Colors.baseColorBlack ?? UIColor(hex: "#1E1E1E")
            label.font = UIFont.GilroyBold(ofSize: 10)
            weekdayStackView.addArrangedSubview(label)
        }

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AttendanceCalendarCell.self, forCellWithReuseIdentifier: AttendanceCalendarCell.reuseIdentifier)

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.numberOfLines = 0
        summaryLabel.textColor = Colors.baseColorBlack ?? UIColor(hex: "#2B2B2B")
        summaryLabel.font = UIFont.GilroyRegular(ofSize: 15)

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(monthStackView)
        view.addSubview(weekdayStackView)
        view.addSubview(collectionView)
        view.addSubview(summaryLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 17),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),

            monthStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
            monthStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 52),
            monthStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -52),
            monthStackView.heightAnchor.constraint(equalToConstant: 32),

            previousButton.widthAnchor.constraint(equalToConstant: 36),
            previousButton.heightAnchor.constraint(equalToConstant: 32),
            nextButton.widthAnchor.constraint(equalToConstant: 36),
            nextButton.heightAnchor.constraint(equalToConstant: 32),

            weekdayStackView.topAnchor.constraint(equalTo: monthStackView.bottomAnchor, constant: 18),
            weekdayStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            weekdayStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 18),

            collectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: weekdayStackView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: weekdayStackView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 276),

            summaryLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 28),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)
        ])
    }

    func monthNavigationButton(imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = Colors.baseColorBlack ?? UIColor(hex: "#1E1E1E")
        return button
    }

    func reloadMonth() {
        days = makeDays(for: visibleMonth)
        monthLabel.text = monthTitle(for: visibleMonth)
        updateSummary()
        collectionView.reloadData()
    }

    func makeDays(for month: Date) -> [AttendanceCalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let daysRange = calendar.range(of: .day, in: .month, for: month) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyCount = (firstWeekday + 5) % 7
        let attendance = attendanceByMonth[monthKey(for: month)] ?? [:]
        var result: [AttendanceCalendarDay] = Array(
            repeating: AttendanceCalendarDay(day: nil, status: .none, isCurrentMonth: false),
            count: leadingEmptyCount
        )

        daysRange.forEach { day in
            result.append(AttendanceCalendarDay(
                day: day,
                status: attendance[day] ?? .none,
                isCurrentMonth: true
            ))
        }

        let trailingCount = (7 - (result.count % 7)) % 7
        if trailingCount > 0 {
            (1...trailingCount).forEach { day in
                result.append(AttendanceCalendarDay(day: day, status: .none, isCurrentMonth: false))
            }
        }

        return result
    }

    func updateSummary() {
        let attendance = attendanceByMonth[monthKey(for: visibleMonth)] ?? [:]
        let totalMarkedDays = attendance.count
        let presentDays = attendance.values.filter { $0 == .present }.count
        let percentage = totalMarkedDays == 0 ? 0 : Int(round((Double(presentDays) / Double(totalMarkedDays)) * 100))

        let text = "Attendance for the month : \(presentDays)/\(totalMarkedDays) (\(percentage)%)"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(
            .font,
            value: UIFont.GilroyBold(ofSize: 15),
            range: (text as NSString).range(of: "Attendance for the month :")
        )
        summaryLabel.attributedText = attributedText
    }

    func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func monthKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", components.year ?? 0, components.month ?? 0)
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func previousMonthTapped() {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: visibleMonth) else { return }
        visibleMonth = previousMonth
        reloadMonth()
    }

    @objc func nextMonthTapped() {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: visibleMonth) else { return }
        visibleMonth = nextMonth
        reloadMonth()
    }
}

extension AttendanceViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AttendanceCalendarCell.reuseIdentifier,
            for: indexPath
        ) as? AttendanceCalendarCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: days[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(collectionView.bounds.width / 7)
        return CGSize(width: width, height: 36)
    }
}

private final class AttendanceCalendarCell: UICollectionViewCell {
    static let reuseIdentifier = "AttendanceCalendarCell"

    private let circleView = CircleView()
    private let dayLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = 16
    }

    func configure(with day: AttendanceCalendarDay) {
        if let dayNumber = day.day {
            dayLabel.text = "\(dayNumber)"
        } else {
            dayLabel.text = ""
        }

        circleView.backgroundColor = day.status.fillColor
        dayLabel.textColor = day.status.usesLightText ? .white : (day.isCurrentMonth ? Colors.baseColorBlack ?? UIColor(hex: "#1E1E1E") : UIColor(hex: "#C4C4C4"))
        dayLabel.font = UIFont.GilroyBold(ofSize: 9)
    }
}

private extension AttendanceCalendarCell {
    func setupViews() {
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .clear
        circleView.clipsToBounds = true
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = 16
        circleView.layer.cornerCurve = .circular

        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.textAlignment = .center

        contentView.addSubview(circleView)
        circleView.addSubview(dayLabel)

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 32),
            circleView.heightAnchor.constraint(equalToConstant: 32),

            dayLabel.leadingAnchor.constraint(equalTo: circleView.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: circleView.trailingAnchor),
            dayLabel.topAnchor.constraint(equalTo: circleView.topAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: circleView.bottomAnchor)
        ])
    }
}

private final class CircleView: UIView {
    override var bounds: CGRect {
        didSet {
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        layer.cornerCurve = .circular
        layer.masksToBounds = true
    }
}

//
//  NotificationViewController.swift
//  Gradmo
//
//  Created by Philanderer on 08/05/26.
//

import UIKit

struct NotificationItem {
    let message: String
    let timeText: String
    let image: UIImage?
    let tintColor: UIColor
    let backgroundColor: UIColor
    var isRead: Bool
}

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let notificationCellReuseIdentifier = String(describing: NotificationTableViewCell.self)
    private var notifications: [NotificationItem] = []
    private var dropdownView: UIView?
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No notifications yet"
        label.textAlignment = .center
        label.font = UIFont.GilroyMedium(ofSize: 14)
        label.textColor = UIColor(hex: "#7A7A7A")
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadNotifications()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        hideDropdown()
        if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            tabBarController?.selectedIndex = CustomTabBarController.AppTab.home.rawValue
        }
    }
    
    @IBAction func expandButtonTapped(_ sender: UIButton!){
        toggleDropdown(from: sender)
    }

}

private extension NotificationViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerXib(NotificationTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 93
    }

    func loadNotifications() {
        notifications = [
            NotificationItem(
                message: "Your upcoming class starts at 4:00 PM today.",
                timeText: "Today",
                image: UIImage(systemName: "bell.fill"),
                tintColor: UIColor(hex: "#3D82F2"),
                backgroundColor: UIColor(hex: "#EAF2FF"),
                isRead: false
            ),
            NotificationItem(
                message: "New study material has been added to your batch library.",
                timeText: "Yesterday",
                image: UIImage(systemName: "book.closed.fill"),
                tintColor: UIColor(hex: "#2EAD6B"),
                backgroundColor: UIColor(hex: "#EAF8F1"),
                isRead: false
            ),
            NotificationItem(
                message: "Your payment receipt is ready to view.",
                timeText: "2 days ago",
                image: UIImage(systemName: "checkmark.seal.fill"),
                tintColor: UIColor(hex: "#F59E0B"),
                backgroundColor: UIColor(hex: "#FFF6E5"),
                isRead: true
            ),
            NotificationItem(
                message: "Assessment results for Science Foundation are available.",
                timeText: "3 days ago",
                image: UIImage(systemName: "doc.text.fill"),
                tintColor: UIColor(hex: "#7C3AED"),
                backgroundColor: UIColor(hex: "#F2EAFE"),
                isRead: false
            ),
            NotificationItem(
                message: "Attendance has been marked for your latest class.",
                timeText: "4 days ago",
                image: UIImage(systemName: "person.badge.clock.fill"),
                tintColor: UIColor(hex: "#0EA5E9"),
                backgroundColor: UIColor(hex: "#E6F6FE"),
                isRead: true
            ),
            NotificationItem(
                message: "A new promo code is available for your next enrollment.",
                timeText: "1 week ago",
                image: UIImage(systemName: "tag.fill"),
                tintColor: UIColor(hex: "#EF4444"),
                backgroundColor: UIColor(hex: "#FEECEC"),
                isRead: false
            )
        ]
        updateEmptyState()
        tableView.reloadData()
    }

    func updateEmptyState() {
        tableView.backgroundView = notifications.isEmpty ? emptyStateLabel : nil
    }

    var displayedNotifications: [NotificationItem] {
        notifications
    }

    func toggleDropdown(from sender: UIButton) {
        if dropdownView != nil {
            hideDropdown()
            return
        }

        showDropdown(from: sender)
    }

    func showDropdown(from sender: UIButton) {
        hideDropdown()

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.12
        container.layer.shadowRadius = 10
        container.layer.shadowOffset = CGSize(width: 0, height: 4)

        let stackView = UIStackView(arrangedSubviews: [
            makeDropdownButton(title: "Mark all as read", action: #selector(markAllAsReadButtonTapped)),
            makeDropdownButton(title: "Delete all", action: #selector(deleteAllButtonTapped))
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        container.addSubview(stackView)
        view.addSubview(container)

        let senderFrame = sender.convert(sender.bounds, to: view)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: senderFrame.maxY + 8),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            container.widthAnchor.constraint(equalToConstant: 170),
            container.heightAnchor.constraint(equalToConstant: 88),

            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        container.alpha = 0
        dropdownView = container
        UIView.animate(withDuration: 0.18) {
            container.alpha = 1
        }
    }

    func makeDropdownButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(title == "Delete all" ? UIColor(hex: "#D35400") : UIColor(hex: "#1F2937"), for: .normal)
        button.titleLabel?.font = UIFont.GilroyMedium(ofSize: 13)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func hideDropdown() {
        guard let dropdownView else { return }
        UIView.animate(withDuration: 0.12) {
            dropdownView.alpha = 0
        } completion: { _ in
            dropdownView.removeFromSuperview()
        }
        self.dropdownView = nil
    }
}

private extension NotificationViewController {
    @objc func markAllAsReadButtonTapped() {
        notifications = notifications.map {
            var notification = $0
            notification.isRead = true
            return notification
        }
        hideDropdown()
        tableView.reloadData()
    }

    @objc func deleteAllButtonTapped() {
        notifications.removeAll()
        hideDropdown()
        updateEmptyState()
        tableView.reloadData()
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedNotifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: notificationCellReuseIdentifier,
            for: indexPath
        ) as? NotificationTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: displayedNotifications[indexPath.row])
        return cell
    }
}

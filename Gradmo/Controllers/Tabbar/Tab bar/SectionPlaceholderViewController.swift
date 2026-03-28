//
//  SectionPlaceholderViewController.swift
//  Gradmo
//

import UIKit

final class SectionPlaceholderViewController: UIViewController {

    private let sectionTitle: String
    private let detailText: String

    init(sectionTitle: String, detailText: String) {
        self.sectionTitle = sectionTitle
        self.detailText = detailText
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension SectionPlaceholderViewController {

    func setupUI() {
        view.backgroundColor = UIColor(hex: "#F5FAFF")

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = sectionTitle
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.GilroyBold(ofSize: 24)
        titleLabel.textColor = UIColor(hex: "#111111")

        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.text = detailText
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.font = UIFont.GilroyRegular(ofSize: 14)
        detailLabel.textColor = UIColor(hex: "#6C6C6C")

        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12

        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 20
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)

        view.addSubview(cardView)
        cardView.addSubview(stackView)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32)
        ])
    }
}

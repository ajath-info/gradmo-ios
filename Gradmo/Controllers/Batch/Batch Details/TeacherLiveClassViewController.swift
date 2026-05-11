//
//  TeacherLiveClassViewController.swift
//  Gradmo
//
//  Created by Codex on 10/05/26.
//

import UIKit

final class TeacherLiveClassViewController: UIViewController {
    var batchID: Int?
    var batchName: String?
    var existingSessionID: String?

    private let themeColor = Colors.themeColor ?? UIColor(hex: "#3D82F2")
    private let fieldBackgroundColor = UIColor(hex: "#EAF6FC")
    private let titleColor = Colors.baseColorBlack ?? UIColor(hex: "#050302")

    private let sessionTextField = UITextField()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        buildLayout()
        applyInitialState()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func startClassTapped() {
        let sessionText = sessionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !sessionText.isEmpty else {
            showToastSafely("Enter Zoom URL or meeting ID")
            return
        }

        existingSessionID = sessionText
        statusLabel.text = "Class is ready to open"
        ZoomManager.shared.openLiveClass(from: self, joinURLString: sessionText)
    }

    @objc private func continueClassTapped() {
        let sessionText = (sessionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
            ?? existingSessionID
        guard let sessionText, !sessionText.isEmpty else {
            showToastSafely("No live class link available")
            return
        }

        ZoomManager.shared.openLiveClass(from: self, joinURLString: sessionText)
    }

    @objc private func endClassTapped() {
        existingSessionID = nil
        sessionTextField.text = ""
        statusLabel.text = "No live class running"
        showToastSafely("Live class cleared for this session")
    }
}

private extension TeacherLiveClassViewController {
    func buildLayout() {
        view.backgroundColor = .white

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft"), for: .normal)
        backButton.tintColor = titleColor
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = "Live Class"
        titleLabel.textColor = titleColor
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)

        let batchLabel = UILabel()
        batchLabel.text = batchName ?? "Batch"
        batchLabel.textColor = titleColor
        batchLabel.font = .systemFont(ofSize: 22, weight: .bold)
        batchLabel.numberOfLines = 0
        batchLabel.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.textColor = UIColor(hex: "#5C5C5C")
        statusLabel.font = .systemFont(ofSize: 15, weight: .regular)
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        sessionTextField.backgroundColor = fieldBackgroundColor
        sessionTextField.textColor = titleColor
        sessionTextField.tintColor = themeColor
        sessionTextField.font = .systemFont(ofSize: 16, weight: .regular)
        sessionTextField.layer.cornerRadius = 24
        sessionTextField.clipsToBounds = true
        sessionTextField.placeholderSet(placeHolder: "Zoom URL or Meeting ID", color: .black)
        sessionTextField.configureFormField(leftPadding: 24, rightPadding: 24)
        sessionTextField.autocapitalizationType = .none
        sessionTextField.autocorrectionType = .no
        sessionTextField.keyboardType = .URL
        sessionTextField.translatesAutoresizingMaskIntoConstraints = false

        let startButton = makePrimaryButton(title: "Start Live Class")
        startButton.addTarget(self, action: #selector(startClassTapped), for: .touchUpInside)

        let continueButton = makeSecondaryButton(title: "Continue Class")
        continueButton.addTarget(self, action: #selector(continueClassTapped), for: .touchUpInside)

        let endButton = makeDangerButton(title: "End Class")
        endButton.addTarget(self, action: #selector(endClassTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [startButton, continueButton, endButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        [headerView, batchLabel, statusLabel, sessionTextField, buttonStack].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: headerView.widthAnchor, multiplier: 0.7),

            batchLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 36),
            batchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            batchLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            statusLabel.topAnchor.constraint(equalTo: batchLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: batchLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: batchLabel.trailingAnchor),

            sessionTextField.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 28),
            sessionTextField.leadingAnchor.constraint(equalTo: batchLabel.leadingAnchor),
            sessionTextField.trailingAnchor.constraint(equalTo: batchLabel.trailingAnchor),
            sessionTextField.heightAnchor.constraint(equalToConstant: 50),

            buttonStack.topAnchor.constraint(equalTo: sessionTextField.bottomAnchor, constant: 28),
            buttonStack.leadingAnchor.constraint(equalTo: batchLabel.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: batchLabel.trailingAnchor)
        ])

        [startButton, continueButton, endButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
        }
    }

    func applyInitialState() {
        sessionTextField.text = existingSessionID
        if existingSessionID?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            statusLabel.text = "A live class link is available for this batch"
        } else {
            statusLabel.text = "No live class running"
        }
    }

    func makePrimaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = themeColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func makeSecondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = fieldBackgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func makeDangerButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(hex: "#D64545"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: "#F0C8C8").cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

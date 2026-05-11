//
//  RatingAndReviewViewController.swift
//  Gradmo
//
//  Created by Philanderer on 11/04/26.
//

import UIKit

class RatingAndReviewViewController: UIViewController {

    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: UIButton!

    private let placeholderText = "Write feedback...."
    private let maxRating = 5
    private var selectedRating = 0
    private var starButtons: [UIButton] = []
    private let starColor = UIColor(hex: "#F9A23B")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        submitButton.layer.cornerRadius = submitButton.frame.height / 2
    }
   
    @IBAction func submitButtonTapped(_ sender: UIButton!){
        view.endEditing(true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
}

private extension RatingAndReviewViewController {
    func setupUI() {
        setupRatingView()
        setupTextView()
        setupSubmitButton()
    }

    func setupRatingView() {
        ratingView.subviews.forEach { $0.removeFromSuperview() }
        starButtons.removeAll()

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        ratingView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: ratingView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: ratingView.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: ratingView.trailingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: ratingView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: ratingView.bottomAnchor)
        ])

        for index in 1...maxRating {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index
            button.tintColor = starColor
            button.setPreferredSymbolConfiguration(
                UIImage.SymbolConfiguration(pointSize: 30, weight: .regular),
                forImageIn: .normal
            )
            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            stackView.addArrangedSubview(button)
            starButtons.append(button)
        }

        updateStarSelection()
    }

    func setupTextView() {
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        applyPlaceholder()
    }

    func setupSubmitButton() {
        submitButton.clipsToBounds = true
    }

    func updateStarSelection() {
        for button in starButtons {
            let imageName = button.tag <= selectedRating ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    func applyPlaceholder() {
        textView.text = placeholderText
        textView.textColor = UIColor(named: "baseColor_Gray") ?? .systemGray
    }

    @objc func starButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarSelection()
    }
}

extension RatingAndReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = nil
            textView.textColor = UIColor(named: "baseColor_Black") ?? .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            applyPlaceholder()
        }
    }
}

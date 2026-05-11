//
//  AddQuestionViewController.swift
//  Gradmo
//
//  Created by Philanderer on 10/05/26.
//

import UIKit

class AddQuestionViewController: UIViewController {

    @IBOutlet var questionNumberLabel: UILabel!
    @IBOutlet var browseButton: UIButton!
    
    @IBOutlet var questionTextView: UITextView!
    @IBOutlet var option1TextView: UITextView!
    @IBOutlet var option2TextView: UITextView!
    @IBOutlet var option3TextView: UITextView!
    @IBOutlet var option4TextView: UITextView!
    
    @IBOutlet var CorrectAnswer1Button: UIButton!
    @IBOutlet var CorrectAnswer2Button: UIButton!
    @IBOutlet var CorrectAnswer3Button: UIButton!
    @IBOutlet var CorrectAnswer4Button: UIButton!
    
    @IBOutlet var addQuestionButton: UIButton!
    @IBOutlet var finishTestButton: UIButton!

    private let themeColor = Colors.themeColor ?? UIColor(hex: "#3D82F2")
    private let fieldBackgroundColor = UIColor(hex: "#EAF6FC")
    private let titleColor = Colors.baseColorBlack ?? UIColor(hex: "#050302")
    private let buttonBorderColor = UIColor(hex: "#E3E3E3")
    private var selectedCorrectAnswer = 3
    private var questionNumber = 1
    private var textViewHeightConstraints: [UITextView: NSLayoutConstraint] = [:]
    private var selectedQuestionImage: UIImage?
    private var selectedQuestionImageName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        buildLayout()
        updateCorrectAnswerButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        [questionTextView, option1TextView, option2TextView, option3TextView, option4TextView].forEach {
            guard let textView = $0 else { return }
            adjustTextViewHeight(textView)
        }
    }
  
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func browseButtonTapped(_ sender: UIButton!){
        showUploadOptions(from: sender)
    }
    
    @IBAction func correctAnswer1ButtonTapped(_ sender: UIButton!){
        selectedCorrectAnswer = 1
        updateCorrectAnswerButtons()
    }
    
    @IBAction func correctAnswer2ButtonTapped(_ sender: UIButton!){
        selectedCorrectAnswer = 2
        updateCorrectAnswerButtons()
    }
    
    @IBAction func correctAnswer3ButtonTapped(_ sender: UIButton!){
        selectedCorrectAnswer = 3
        updateCorrectAnswerButtons()
    }
    
    @IBAction func correctAnswer4ButtonTapped(_ sender: UIButton!){
        selectedCorrectAnswer = 4
        updateCorrectAnswerButtons()
    }
    
    @IBAction func addQuestionButtonTapped(_ sender: UIButton!){
        questionNumber += 1
        selectedCorrectAnswer = 3
        questionNumberLabel.text = "Question \(questionNumber)"
        [questionTextView, option1TextView, option2TextView, option3TextView, option4TextView].forEach {
            $0?.text = ""
            guard let textView = $0 else { return }
            adjustTextViewHeight(textView)
        }
        selectedQuestionImage = nil
        selectedQuestionImageName = nil
        updateBrowseButtonSelectionState()
        updateCorrectAnswerButtons()
    }
    
    @IBAction func finishTestButtonTapped(_ sender: UIButton!){
        navigationController?.popToRootViewController(animated: true)
    }

}

private extension AddQuestionViewController {
    func buildLayout() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .white

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let headerView = makeHeader(title: "Add Questions")

        questionNumberLabel = makeSectionLabel("Question 1")
        questionTextView = makeTextView(text: "Question", height: 48)

        browseButton = makeBrowseButton()
        browseButton.addTarget(self, action: #selector(browseButtonTapped(_:)), for: .touchUpInside)

        let imageLabel = makeLargeLabel("Add Image")
        let optionTitleLabel = makeLargeLabel("Add Options")
        option1TextView = makeTextView(text: "Option 1", height: 52)
        option2TextView = makeTextView(text: "Option 2", height: 52)
        option3TextView = makeTextView(text: "Option 3", height: 52)
        option4TextView = makeTextView(text: "Option 4", height: 52)

        let optionsStack = UIStackView(arrangedSubviews: [
            option1TextView,
            option2TextView,
            option3TextView,
            option4TextView
        ])
        optionsStack.axis = .vertical
        optionsStack.spacing = 20
        optionsStack.translatesAutoresizingMaskIntoConstraints = false

        let correctAnswerLabel = makeSectionLabel("Correct Answer")
        CorrectAnswer1Button = makeCorrectAnswerButton(title: "1", tag: 1)
        CorrectAnswer2Button = makeCorrectAnswerButton(title: "2", tag: 2)
        CorrectAnswer3Button = makeCorrectAnswerButton(title: "3", tag: 3)
        CorrectAnswer4Button = makeCorrectAnswerButton(title: "4", tag: 4)

        let answerStack = UIStackView(arrangedSubviews: [
            CorrectAnswer1Button,
            CorrectAnswer2Button,
            CorrectAnswer3Button,
            CorrectAnswer4Button
        ])
        answerStack.axis = .horizontal
        answerStack.distribution = .fillEqually
        answerStack.spacing = 10
        answerStack.translatesAutoresizingMaskIntoConstraints = false

        addQuestionButton = makeSecondaryButton(title: "Add Questions")
        addQuestionButton.addTarget(self, action: #selector(addQuestionButtonTapped(_:)), for: .touchUpInside)

        finishTestButton = makePrimaryButton(title: "Finish Test")
        finishTestButton.addTarget(self, action: #selector(finishTestButtonTapped(_:)), for: .touchUpInside)

        let actionStack = UIStackView(arrangedSubviews: [addQuestionButton, finishTestButton])
        actionStack.axis = .horizontal
        actionStack.distribution = .fillEqually
        actionStack.spacing = 16
        actionStack.translatesAutoresizingMaskIntoConstraints = false

        [
            headerView,
            questionNumberLabel,
            questionTextView,
            imageLabel,
            browseButton,
            optionTitleLabel,
            optionsStack,
            correctAnswerLabel,
            answerStack,
            actionStack
        ].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),

            questionNumberLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 52),
            questionNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            questionNumberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            questionTextView.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 34),
            questionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            questionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            imageLabel.topAnchor.constraint(equalTo: questionTextView.bottomAnchor, constant: 30),
            imageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),

            browseButton.centerYAnchor.constraint(equalTo: imageLabel.centerYAnchor),
            browseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 145),
            browseButton.widthAnchor.constraint(equalToConstant: 137),
            browseButton.heightAnchor.constraint(equalToConstant: 38),

            optionTitleLabel.topAnchor.constraint(equalTo: imageLabel.bottomAnchor, constant: 46),
            optionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            optionTitleLabel.trailingAnchor.constraint(equalTo: questionTextView.trailingAnchor),

            optionsStack.topAnchor.constraint(equalTo: optionTitleLabel.bottomAnchor, constant: 38),
            optionsStack.leadingAnchor.constraint(equalTo: questionTextView.leadingAnchor),
            optionsStack.trailingAnchor.constraint(equalTo: questionTextView.trailingAnchor),

            correctAnswerLabel.topAnchor.constraint(equalTo: optionsStack.bottomAnchor, constant: 42),
            correctAnswerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            correctAnswerLabel.trailingAnchor.constraint(equalTo: questionTextView.trailingAnchor),

            answerStack.topAnchor.constraint(equalTo: correctAnswerLabel.bottomAnchor, constant: 26),
            answerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            answerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35),
            answerStack.heightAnchor.constraint(equalToConstant: 62),

            actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27),
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            actionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            actionStack.heightAnchor.constraint(equalToConstant: 51),
            actionStack.topAnchor.constraint(greaterThanOrEqualTo: answerStack.bottomAnchor, constant: 28)
        ])
    }

    func makeHeader(title: String) -> UIView {
        let header = UIView()
        header.backgroundColor = .white
        header.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft"), for: .normal)
        backButton.tintColor = titleColor
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleColor
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(backButton)
        header.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 15),
            backButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 10),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: header.widthAnchor, multiplier: 0.7)
        ])

        return header
    }

    func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = titleColor
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func makeLargeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func makeTextView(text: String, height: CGFloat) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.textColor = titleColor
        textView.tintColor = themeColor
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.backgroundColor = fieldBackgroundColor
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 32, bottom: 10, right: 24)
        textView.layer.cornerRadius = 24
        textView.clipsToBounds = true
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = textView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        textViewHeightConstraints[textView] = heightConstraint
        return textView
    }

    func makeBrowseButton() -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Browse"
        configuration.image = UIImage(named: "browse")
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .white
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18)

        let button = UIButton(type: .system)
        button.configuration = configuration
        button.backgroundColor = themeColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        return button
    }

    func makeCorrectAnswerButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.setTitleColor(themeColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .regular)
        button.backgroundColor = fieldBackgroundColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false

        let selector: Selector
        switch tag {
        case 1: selector = #selector(correctAnswer1ButtonTapped(_:))
        case 2: selector = #selector(correctAnswer2ButtonTapped(_:))
        case 3: selector = #selector(correctAnswer3ButtonTapped(_:))
        default: selector = #selector(correctAnswer4ButtonTapped(_:))
        }
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    func makePrimaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = themeColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 25.5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: "#2C6EDF").cgColor
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func makeSecondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle(title, for: .normal)
        button.setTitleColor(themeColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.layer.cornerRadius = 25.5
        button.layer.borderWidth = 1
        button.layer.borderColor = buttonBorderColor.cgColor
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func updateCorrectAnswerButtons() {
        let buttons = [
            CorrectAnswer1Button,
            CorrectAnswer2Button,
            CorrectAnswer3Button,
            CorrectAnswer4Button
        ]

        buttons.forEach { button in
            guard let button else { return }
            let isSelected = button.tag == selectedCorrectAnswer
            button.backgroundColor = isSelected ? themeColor : fieldBackgroundColor
            button.setTitleColor(isSelected ? .white : .black, for: .normal)
        }
    }

    func adjustTextViewHeight(_ textView: UITextView) {
        guard let heightConstraint = textViewHeightConstraints[textView] else { return }

        let minimumHeight = ceil((textView.font?.lineHeight ?? 20) + textView.textContainerInset.top + textView.textContainerInset.bottom)
        let fittingWidth = max(textView.bounds.width, view.bounds.width - 48)
        let fittingSize = textView.sizeThatFits(CGSize(width: fittingWidth, height: .greatestFiniteMagnitude))
        let newHeight = max(minimumHeight, ceil(fittingSize.height))
        guard abs(heightConstraint.constant - newHeight) > 0.5 else { return }

        heightConstraint.constant = newHeight
        view.layoutIfNeeded()
    }

    func showUploadOptions(from sourceView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openGallery()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }

        present(alert, animated: true)
    }

    func openGallery() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func updateBrowseButtonSelectionState() {
        var configuration = browseButton.configuration
        configuration?.title = selectedQuestionImageName ?? "Browse"
        browseButton.configuration = configuration
    }
}

extension AddQuestionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight(textView)
    }
}

extension AddQuestionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        selectedQuestionImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        selectedQuestionImageName = "Image Selected"
        updateBrowseButtonSelectionState()
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

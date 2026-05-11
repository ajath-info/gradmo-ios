//
//  CreateAssessmentViewController.swift
//  Gradmo
//
//  Created by Philanderer on 10/05/26.
//

import UIKit

class CreateAssessmentViewController: UIViewController {

    @IBOutlet var testName:UITextField!
    @IBOutlet var testDuration:UITextField!
    @IBOutlet var testDueDate:UITextField!
    @IBOutlet var testDueTime:UITextField!

    private let themeColor = Colors.themeColor ?? UIColor(hex: "#3D82F2")
    private let fieldBackgroundColor = UIColor(hex: "#EAF6FC")
    private let titleColor = Colors.baseColorBlack ?? UIColor(hex: "#050302")
    private let mutedTextColor = UIColor.black
    private let dueDatePicker = UIDatePicker()
    private let dueTimePicker = UIDatePicker()
    private lazy var dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    private lazy var dueTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        buildLayout()
        configureDueDateAndTimePickers()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addQuestionButtonTapped(_ sender: UIButton!){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(
            withIdentifier: "AddQuestionViewController"
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

private extension CreateAssessmentViewController {
    func buildLayout() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .white

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let headerView = makeHeader(title: "Assessment")
        let fieldsStack = UIStackView()
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 30
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false

        testName = makeTextField(placeholder: "Test Name")
        testDuration = makeTextField(placeholder: "Duration (In Minutes)", keyboardType: .numberPad)
        testDueDate = makeTextField(placeholder: "Due Date")
        testDueTime = makeTextField(placeholder: "Due Time")

        [testName, testDuration, testDueDate, testDueTime].forEach { fieldsStack.addArrangedSubview($0) }

        let addButton = makePrimaryButton(title: "Add Questions")
        addButton.addTarget(self, action: #selector(addQuestionButtonTapped(_:)), for: .touchUpInside)

        contentView.addSubview(headerView)
        contentView.addSubview(fieldsStack)
        contentView.addSubview(addButton)

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

            fieldsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 54),
            fieldsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            fieldsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.topAnchor.constraint(greaterThanOrEqualTo: fieldsStack.bottomAnchor, constant: 40)
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

    func makeTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = fieldBackgroundColor
        textField.textColor = titleColor
        textField.tintColor = themeColor
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 24
        textField.clipsToBounds = true
        textField.keyboardType = keyboardType
        textField.placeholderSet(placeHolder: placeholder, color: mutedTextColor)
        textField.configureFormField(leftPadding: 36, rightPadding: 24)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return textField
    }

    func makePrimaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = themeColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func configureDueDateAndTimePickers() {
        let today = Calendar.current.startOfDay(for: Date())

        dueDatePicker.datePickerMode = .date
        dueDatePicker.minimumDate = today
        dueDatePicker.date = max(testDueDate.text.flatMap { dueDateFormatter.date(from: $0) } ?? today, today)
        dueDatePicker.preferredDatePickerStyle = .inline

        dueTimePicker.datePickerMode = .time
        dueTimePicker.locale = Locale(identifier: "en_US_POSIX")
        dueTimePicker.preferredDatePickerStyle = .wheels

        testDueDate.inputView = dueDatePicker
        testDueDate.inputAccessoryView = makePickerToolbar(doneAction: #selector(didTapDueDateDone), cancelAction: #selector(didTapPickerCancel))
        testDueDate.addTarget(self, action: #selector(didBeginDueDateEditing), for: .editingDidBegin)

        testDueTime.inputView = dueTimePicker
        testDueTime.inputAccessoryView = makePickerToolbar(doneAction: #selector(didTapDueTimeDone), cancelAction: #selector(didTapPickerCancel))
        testDueTime.addTarget(self, action: #selector(didBeginDueTimeEditing), for: .editingDidBegin)
    }

    func makePickerToolbar(doneAction: Selector, cancelAction: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancelAction),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: doneAction)
        ]
        return toolbar
    }
}

private extension CreateAssessmentViewController {
    @objc func didBeginDueDateEditing() {
        let today = Calendar.current.startOfDay(for: Date())
        dueDatePicker.minimumDate = today
        dueDatePicker.date = max(testDueDate.text.flatMap { dueDateFormatter.date(from: $0) } ?? today, today)
    }

    @objc func didBeginDueTimeEditing() {
        dueTimePicker.date = testDueTime.text.flatMap { dueTimeFormatter.date(from: $0) } ?? Date()
    }

    @objc func didTapDueDateDone() {
        testDueDate.text = dueDateFormatter.string(from: dueDatePicker.date)
        view.endEditing(true)
    }

    @objc func didTapDueTimeDone() {
        testDueTime.text = dueTimeFormatter.string(from: dueTimePicker.date)
        view.endEditing(true)
    }

    @objc func didTapPickerCancel() {
        view.endEditing(true)
    }
}

//
//  AssessmentViewController.swift
//  Gradmo
//
//  Created by Philanderer on 22/04/26.
//

import UIKit

struct AssessmentQuestion {
    let question: String
    let image: UIImage?
    let options: [String]
    let correctOptionIndex: Int
}

class AssessmentViewController: UIViewController {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var assessmentAnswersOptionTableView: UITableView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionNumberOutOfTotalLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var questionProgressView: UIProgressView!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private let questions: [AssessmentQuestion] = [
        AssessmentQuestion(
            question: "Which accounting principle says that revenue should be recorded when it is earned, not necessarily when cash is received?",
            image: nil,
            options: [
                "Accrual concept",
                "Business entity concept",
                "Money measurement concept",
                "Dual aspect concept"
            ],
            correctOptionIndex: 0
        ),
        AssessmentQuestion(
            question: "A business purchased goods worth Rs. 20,000 on credit. Which option correctly explains the effect of this transaction?",
            image: nil,
            options: [
                "Purchases increase and cash decreases because every purchase immediately reduces cash balance.",
                "Purchases increase and creditors increase because the goods were bought on credit and payment will be made later.",
                "Capital increases and stock decreases because goods bought on credit are treated as owner contribution.",
                "Sales increase and debtors increase because goods entered the business for resale."
            ],
            correctOptionIndex: 1
        ),
        AssessmentQuestion(
            question: "What is the main purpose of preparing a trial balance?",
            image: nil,
            options: [
                "To check the arithmetical accuracy of ledger posting by comparing total debit balances with total credit balances.",
                "To calculate the final profit of the business without preparing any other financial statement.",
                "To record all cash and bank transactions in chronological order.",
                "To replace journal entries when the business has a large number of transactions."
            ],
            correctOptionIndex: 0
        )
    ]

    private var currentQuestionIndex = 0
    private var selectedOptionIndex: Int?
    private var revealedAnswerIndex: Int?
    private var optionsTableHeightConstraint: NSLayoutConstraint?
    private var optionsTableBottomConstraint: NSLayoutConstraint?
    private weak var parentScrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupTableView()
        applyQuestion()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateOptionsTableHeight()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton!){
        revealedAnswerIndex = currentQuestion.correctOptionIndex
        assessmentAnswersOptionTableView.reloadData()
    }

    @IBAction func nextButtonTapped(_ sender: UIButton!){
        guard currentQuestionIndex < questions.count - 1 else {
            navigationController?.popViewController(animated: true)
            return
        }

        currentQuestionIndex += 1
        selectedOptionIndex = nil
        revealedAnswerIndex = nil
        applyQuestion()
    }
    
}

private extension AssessmentViewController {
    var currentQuestion: AssessmentQuestion {
        questions[currentQuestionIndex]
    }

    func configureUI() {
        answerButton.applyCapsuleCornerRadius()
        nextButton.applyCapsuleCornerRadius()

        questionNumberLabel.font = UIFont.GilroyMedium(ofSize: 17)
        questionNumberOutOfTotalLabel.font = UIFont.GilroyMedium(ofSize: 17)
        questionLabel.font = UIFont.GilroyMedium(ofSize: 17)
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = .byWordWrapping
        answerButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)
        nextButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 15)

        questionView.layer.cornerRadius = 12
        questionProgressView.progress = 0
        questionProgressView.layer.cornerRadius = 2
        questionProgressView.clipsToBounds = true
        questionImageView.layer.cornerRadius = 12
        questionImageView.clipsToBounds = true
        (questionLabel.superview as? UIStackView)?.alignment = .fill
    }

    func setupTableView() {
        assessmentAnswersOptionTableView.delegate = self
        assessmentAnswersOptionTableView.dataSource = self
        assessmentAnswersOptionTableView.registerXib(AssessmentAnswersOptionTableViewCell.self)
        assessmentAnswersOptionTableView.rowHeight = UITableView.automaticDimension
        assessmentAnswersOptionTableView.estimatedRowHeight = 92
        assessmentAnswersOptionTableView.isScrollEnabled = false
        assessmentAnswersOptionTableView.separatorStyle = .none
        assessmentAnswersOptionTableView.backgroundColor = .clear
        assessmentAnswersOptionTableView.showsVerticalScrollIndicator = false
        configureFlexibleOptionsTableHeight()
    }

    func applyQuestion() {
        let question = currentQuestion
        let questionNumber = currentQuestionIndex + 1
        let totalQuestions = questions.count

        questionNumberLabel.text = "Question \(questionNumber)"
        questionNumberOutOfTotalLabel.text = "\(questionNumber)/\(totalQuestions)"
        questionLabel.text = question.question
        questionImageView.image = question.image
        applyQuestionImage(question.image)
        questionProgressView.setProgress(Float(questionNumber) / Float(totalQuestions), animated: true)
        nextButton.setTitle(currentQuestionIndex == questions.count - 1 ? "Finish" : "Next", for: .normal)
        assessmentAnswersOptionTableView.reloadData()
        DispatchQueue.main.async { [weak self] in
            self?.updateOptionsTableHeight()
            self?.scrollAssessmentToTop()
        }
    }

    func optionTitle(for index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return index < letters.count ? letters[index] : "\(index + 1)"
    }

    func configureFlexibleOptionsTableHeight() {
        optionsTableBottomConstraint = assessmentAnswersOptionTableView.superview?.constraints.first {
            ($0.firstItem as? UITableView) == assessmentAnswersOptionTableView && $0.firstAttribute == .bottom
                || ($0.secondItem as? UITableView) == assessmentAnswersOptionTableView && $0.secondAttribute == .bottom
        }
        optionsTableBottomConstraint?.isActive = false

        optionsTableHeightConstraint = assessmentAnswersOptionTableView.heightAnchor.constraint(equalToConstant: 1)
        optionsTableHeightConstraint?.priority = .required
        optionsTableHeightConstraint?.isActive = true

        if let buttonStackView = answerButton.superview {
            let stackTopConstraint = buttonStackView.topAnchor.constraint(
                equalTo: assessmentAnswersOptionTableView.bottomAnchor,
                constant: 20
            )
            stackTopConstraint.priority = .required
            stackTopConstraint.isActive = true
        }
    }

    func applyQuestionImage(_ image: UIImage?) {
        questionImageView.image = image
        let shouldHideImage = image == nil
        questionImageView.isHidden = shouldHideImage
        questionImageView.superview?.isHidden = shouldHideImage
    }

    func updateOptionsTableHeight() {
        view.layoutIfNeeded()
        assessmentAnswersOptionTableView.layoutIfNeeded()
        let contentHeight = assessmentAnswersOptionTableView.contentSize.height
        guard optionsTableHeightConstraint?.constant != contentHeight else { return }

        optionsTableHeightConstraint?.constant = contentHeight
        view.layoutIfNeeded()
    }

    func scrollAssessmentToTop() {
        let scrollView = parentScrollView ?? findParentScrollView(from: questionView)
        parentScrollView = scrollView
        scrollView?.setContentOffset(.zero, animated: false)
    }

    func findParentScrollView(from view: UIView?) -> UIScrollView? {
        guard let view else { return nil }
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        return findParentScrollView(from: view.superview)
    }
}

extension AssessmentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentQuestion.options.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: AssessmentAnswersOptionTableViewCell.self),
            for: indexPath
        ) as? AssessmentAnswersOptionTableViewCell else {
            return UITableViewCell()
        }

        let isSelected = selectedOptionIndex == indexPath.row
        let isCorrect = revealedAnswerIndex == indexPath.row
        cell.configure(
            optionNumber: optionTitle(for: indexPath.row),
            answer: currentQuestion.options[indexPath.row],
            isSelected: isSelected,
            isCorrect: isCorrect
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOptionIndex = indexPath.row
        tableView.reloadData()
        updateOptionsTableHeight()
    }
}

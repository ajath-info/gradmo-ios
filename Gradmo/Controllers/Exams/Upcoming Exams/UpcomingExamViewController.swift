//
//  UpcomingExamViewController.swift
//  Gradmo
//
//  Created by Philanderer on 13/04/26.
//

import UIKit

struct UpcomingExamItem {
    let title: String
    let questionCount: Int
    let duration: String
    let completeBy: String
    let subject: String
    let grade: String
    let image: UIImage?
    let buttonTitle: String
}

class UpcomingExamViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let exams: [UpcomingExamItem] = [
        UpcomingExamItem(
            title: "Commerce Mid Term Assessment - Financial Accounting",
            questionCount: 50,
            duration: "60 mins",
            completeBy: "7:00 PM, Apr 18, 2026",
            subject: "Commerce",
            grade: "Grade 12",
            image: UIImage(named: "bannerPlaceholder"),
            buttonTitle: "Start Assessment"
        ),
        UpcomingExamItem(
            title: "Business Studies Weekly Mock Test",
            questionCount: 35,
            duration: "45 mins",
            completeBy: "5:30 PM, Apr 20, 2026",
            subject: "Business",
            grade: "Grade 11",
            image: UIImage(named: "videoBoxPlaceholder"),
            buttonTitle: "Start Assessment"
        ),
        UpcomingExamItem(
            title: "Economics Practice Test - Demand And Supply",
            questionCount: 40,
            duration: "50 mins",
            completeBy: "6:00 PM, Apr 23, 2026",
            subject: "Economics",
            grade: "Grade 12",
            image: UIImage(named: "bannerPlaceholder"),
            buttonTitle: "Start Assessment"
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }

}

private extension UpcomingExamViewController {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXib(UpcomingExamCollectionViewCell.self)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
    }
}

extension UpcomingExamViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        exams.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: UpcomingExamCollectionViewCell.self),
            for: indexPath
        ) as? UpcomingExamCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: exams[indexPath.item])
        cell.startAssessmentButton.tag = indexPath.item
        cell.startAssessmentButton.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.startAssessmentButton.addTarget(self, action: #selector(startAssessmentButtonTapped(_:)), for: .touchUpInside)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 420)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
}

private extension UpcomingExamViewController {
    @objc func startAssessmentButtonTapped(_ sender: UIButton) {
        openAssessment()
    }

    func openAssessment() {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let assessmentViewController = storyboard.instantiateViewController(
            withIdentifier: "AssessmentViewController"
        ) as? AssessmentViewController else {
            return
        }

        assessmentViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(assessmentViewController, animated: true)
    }
}

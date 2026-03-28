//
//  OnboardingViewController.swift
//  Gradmo
//
//  Created by Philanderer on 14/03/26.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    var slides: [OnboardingSlide] = []
    var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        slides = [
            OnboardingSlide(image: UIImage(named: "onbardingStudent") ?? UIImage()),
            OnboardingSlide(image: UIImage(named: "onbardingTeacher") ?? UIImage()),
            OnboardingSlide(image: UIImage(named: "onbardingInstitute") ?? UIImage())
        ]

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.isPagingEnabled = true
        
//        collectionView.isScrollEnabled = false

        collectionView.reloadData()

        updateNextButtonTitle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Helpers

    private func markOnboardingSeen() {
        UserDefaults.standard.set(true, forKey: LoginKeys.didSeeOnboarding)
    }

    private func updateNextButtonTitle() {
        let isLastPage = currentPage == slides.count - 1
        nextButton.setTitle(isLastPage ? "Get Started" : "Next", for: .normal)
    }

    // MARK: - Actions

    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            markOnboardingSeen()
            let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterAsViewController") as! RegisterAsViewController
            self.navigationController?.pushViewController(vc, animated: true)
           } else {

               currentPage += 1

               let xOffset = CGFloat(currentPage) * collectionView.frame.width

               collectionView.setContentOffset(
                   CGPoint(x: xOffset, y: collectionView.contentOffset.y),
                   animated: true
               )

               pageControl.currentPage = currentPage
               updateNextButtonTitle()
           }
    }

    @IBAction func skipButtonClicked(_ sender: UIButton) {
        markOnboardingSeen()
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterAsViewController") as! RegisterAsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnboardingCollectionViewCell

        cell.setup(slides[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(
            width: collectionView.bounds.width,
            height: collectionView.bounds.height
        )
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = currentPage
        updateNextButtonTitle()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
}

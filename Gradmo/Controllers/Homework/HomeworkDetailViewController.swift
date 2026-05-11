//
//  HomeworkDetailViewController.swift
//  Gradmo
//
//  Created by Philanderer on 11/05/26.
//

import UIKit

class HomeworkDetailViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var homeworkTitleLabel: UILabel!
    @IBOutlet weak var homeworkDateLabel: UILabel!
    @IBOutlet weak var homeworkContentLabel: UILabel!
    @IBOutlet weak var homeworkImageLabel: UIImageView!
    @IBOutlet weak var attachementButton: UIButton!

    var homeworkItem: HomeworkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func attachementButtonTapped(_ sender: UIButton!){
        guard let attachmentURL = homeworkItem?.attachmentURL else {
            showToastSafely("No attachment available")
            return
        }

        UIApplication.shared.open(attachmentURL)
    }
    
}

private extension HomeworkDetailViewController {
    func setupUI() {
        headerLabel.text = "Homework Details"

        guard let homeworkItem else {
            homeworkTitleLabel.text = "Homework"
            homeworkDateLabel.text = ""
            homeworkContentLabel.text = ""
            homeworkImageLabel.image = UIImage(named: "institutePlaceholder")
            attachementButton.isHidden = true
            return
        }

        homeworkTitleLabel.text = homeworkItem.title
        homeworkDateLabel.text = homeworkItem.dateText
        homeworkContentLabel.text = homeworkItem.content
        homeworkImageLabel.image = homeworkItem.image ?? UIImage(named: "institutePlaceholder")
        attachementButton.isHidden = homeworkItem.attachmentURL == nil
        attachementButton.layer.cornerRadius = 8
        attachementButton.clipsToBounds = true
    }
}

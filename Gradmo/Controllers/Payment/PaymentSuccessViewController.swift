//
//  PaymentSuccessViewController.swift
//  Gradmo
//
//  Created by Philanderer on 10/04/26.
//

import UIKit

class PaymentSuccessViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    var paymentID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
        headingLabel.font = UIFont.GilroyMedium(ofSize: 20)
        subHeadingLabel.font = UIFont.GilroyMedium(ofSize: 18)
    }

    @IBAction func continueButtonTapped(_ sender: UIButton!) {
        if let navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    

}

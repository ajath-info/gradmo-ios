//
//  PaymentPlanViewController.swift
//  swift
//
//  Created by Rishabh   on 09/04/26.
//

import UIKit

class PaymentPlanViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet weak var paymentPlanView1: UIView!
    @IBOutlet weak var paymentPlanView2: UIView!
    @IBOutlet weak var tutionFeeLabel: UILabel!

    var paymentContext: PaymentCheckoutContext?
    var onPaymentSuccess: (() -> Void)?
    private var selectedPlanIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupUI()
    }

    @IBAction func backButtonTapped(_ sender: UIButton!) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func continueButtonTapped(_ sender: UIButton!) {
        openPaymentSummary()
    }

    @IBAction func paymentPlan1ButtonTapped(_ sender: UIButton!) {
        selectedPlanIndex = 0
        applySelectedPlan()
    }

    @IBAction func paymentPlan2ButtonTapped(_ sender: UIButton!) {
        selectedPlanIndex = 1
        applySelectedPlan()
    }
    

}

extension PaymentPlanViewController{
    func setupUI(){
        headingLabel.font = UIFont.GilroyMedium(ofSize: 25)
        selectedPlanIndex = 1

        paymentPlanView1.layer.cornerRadius = 12
        paymentPlanView2.layer.cornerRadius = 12
        paymentPlanView1.layer.masksToBounds = true
        paymentPlanView2.layer.masksToBounds = true
        ContinueButton.layer.cornerRadius = self.ContinueButton.frame.height / 2
        paymentPlanView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPlatformPlan)))
        paymentPlanView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectTuitionPlan)))
        paymentPlanView1.isUserInteractionEnabled = true
        paymentPlanView2.isUserInteractionEnabled = true
        tutionFeeLabel.text = PaymentCheckoutContext.displayAmount(paymentContext?.batchPrice ?? 0)
        applySelectedPlan()
//        ContinueButton.backgroundColor = UIColor.
//        paymentPlanView1.backgroundColor = UIColor.
//        paymentPlanView2.backgroundColor = UIColor.
    }

    @objc func selectPlatformPlan() {
        selectedPlanIndex = 0
        applySelectedPlan()
    }

    @objc func selectTuitionPlan() {
        selectedPlanIndex = 1
        applySelectedPlan()
    }

    func applySelectedPlan() {
        let isPlan1Selected = selectedPlanIndex == 0
        paymentPlanView1.layer.borderWidth = isPlan1Selected ? 2 : 0
        paymentPlanView2.layer.borderWidth = isPlan1Selected ? 0 : 2
        paymentPlanView1.layer.borderColor = UIColor.white.cgColor
        paymentPlanView2.layer.borderColor = UIColor.white.cgColor
        paymentPlanView1.alpha = 1
        paymentPlanView2.alpha = 1
    }

    func openPaymentSummary() {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let paymentSummaryViewController = storyboard.instantiateViewController(
            withIdentifier: "PaymentSummaryViewController"
        ) as? PaymentSummaryViewController else {
            return
        }

        paymentSummaryViewController.paymentContext = paymentContext
        paymentSummaryViewController.onPaymentSuccess = onPaymentSuccess
        paymentSummaryViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(paymentSummaryViewController, animated: true)
    }
}

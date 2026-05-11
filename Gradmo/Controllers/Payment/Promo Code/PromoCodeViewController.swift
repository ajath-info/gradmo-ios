//
//  PromoCodeViewController.swift
//  Gradmo
//
//  Created by Philanderer on 10/04/26.
//

import UIKit

class PromoCodeViewController: UIViewController {

    @IBOutlet weak var promoCodeTextField: UITextField!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var applyTextFieldButton: UIButton!
    @IBOutlet weak var promoCodeTableview: UITableView!

    var paymentContext: PaymentCheckoutContext?
    var appliedPromoCode: AppliedPromoCode?
    var onPromoCodeApplied: ((AppliedPromoCode) -> Void)?
    var enrollmentFeeAmount: Double = 0

    private let promoCodeCellReuseIdentifier = String(describing: PromoCodeTableViewCell.self)
    private var availablePromoCodes: [PromoCode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton.applyCapsuleCornerRadius()
        promoCodeTextField.layer.cornerRadius = 12
        promoCodeTextField.text = appliedPromoCode?.code
        setupTableView()
        fetchPromoCodes()
    }
   
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyTextFieldButtonTapped(_ sender: UIButton!){
        applySelectedPromoCode()
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton!){
        applySelectedPromoCode()
    }

}

private extension PromoCodeViewController {
    func setupTableView() {
        promoCodeTableview.delegate = self
        promoCodeTableview.dataSource = self
        promoCodeTableview.registerXib(PromoCodeTableViewCell.self)
        promoCodeTableview.separatorStyle = .none
        promoCodeTableview.backgroundColor = .clear
        promoCodeTableview.showsVerticalScrollIndicator = false
        promoCodeTableview.rowHeight = UITableView.automaticDimension
        promoCodeTableview.estimatedRowHeight = 70
    }

    func fetchPromoCodes() {
        guard let batchID = paymentContext?.batchID else {
            showToastSafely("Batch details are missing")
            return
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                let promoCodes = try await PromoCodeService.fetchPromoCodes(batchID: batchID)
                await MainActor.run {
                    self.availablePromoCodes = promoCodes
                    self.promoCodeTableview.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.showToastSafely(Self.errorMessage(from: error))
                }
            }
        }
    }

    func applySelectedPromoCode() {
        view.endEditing(true)

        let enteredCode = promoCodeTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased() ?? ""

        guard !enteredCode.isEmpty else {
            showToastSafely("Please enter promo code")
            return
        }

        guard !availablePromoCodes.isEmpty else {
            showToastSafely("Promo codes are not available right now")
            return
        }

        guard let matchedPromoCode = availablePromoCodes.first(where: { $0.normalizedCode == enteredCode }) else {
            showToastSafely("Invalid promo code")
            return
        }

        guard matchedPromoCode.isActive else {
            showToastSafely("This promo code is inactive")
            return
        }

        guard matchedPromoCode.isWithinValidityRange else {
            showToastSafely("This promo code has expired")
            return
        }

        guard matchedPromoCode.isUsageAvailable else {
            showToastSafely("This promo code is no longer available")
            return
        }

        guard let paymentContext else {
            showToastSafely("Payment details are missing")
            return
        }

        let grandTotalBeforePromo = paymentContext.tuitionFee + enrollmentFeeAmount
        let discountAmount = min(matchedPromoCode.discountAmount(for: grandTotalBeforePromo), grandTotalBeforePromo)

        guard discountAmount > 0 else {
            showToastSafely("This promo code is not applicable")
            return
        }

        onPromoCodeApplied?(
            AppliedPromoCode(
                promoCodeID: matchedPromoCode.promoCodeID,
                code: matchedPromoCode.code,
                discountAmount: discountAmount
            )
        )
        navigationController?.popViewController(animated: true)
    }

    static func errorMessage(from error: Error) -> String {
        switch error {
        case NetworkError.noInternetConnection:
            return "No internet connection"
        case NetworkError.apiError(let message),
             NetworkError.requestFailed(let message),
             NetworkError.decodingError(let message):
            return message
        case NetworkError.validation(let response):
            return response.error.first?.message ?? "Unable to fetch promo codes"
        default:
            return "Unable to fetch promo codes"
        }
    }
}

extension PromoCodeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availablePromoCodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: promoCodeCellReuseIdentifier,
            for: indexPath
        ) as? PromoCodeTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: availablePromoCodes[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let promoCode = availablePromoCodes[indexPath.row]
        promoCodeTextField.text = promoCode.code
    }
}

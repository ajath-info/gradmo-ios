//
//  PaymentSummaryViewController.swift
//  Gradmo
//
//  Created by Philanderer on 10/04/26.
//

import UIKit

#if canImport(Razorpay)
import Razorpay
#endif

class PaymentSummaryViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var checkoutTitleLabel: UILabel!
    @IBOutlet weak var tutionFeeLabel: UILabel!
    @IBOutlet weak var tutionFeeAmountLabel: UILabel!
    @IBOutlet weak var batchEnrollmentFeeLabel: UILabel!
    @IBOutlet weak var batchEnrollmentFeeAmountLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var subTotalMonthsLabel: UILabel!
    @IBOutlet weak var subTotalAmountLabel: UILabel!
    @IBOutlet weak var subtotal12MonthsTotalLabel: UILabel!
    @IBOutlet weak var GrandTotalHeaderLabel: UILabel!
    @IBOutlet weak var grandTotalSubTotalLabel: UILabel!
    @IBOutlet weak var grandTotalSubTotalAmountLabel: UILabel!
    @IBOutlet weak var grandTotalOneTimePlatformFeeLabel: UILabel!
    @IBOutlet weak var grandTotalOneTimePlatformFeeAmountLabel: UILabel!
    @IBOutlet weak var grandTotalAmountLabel: UILabel!
    @IBOutlet weak var promoCodeTitleLabel: UILabel!
    @IBOutlet weak var promoCodeTextField: UITextField!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var makePaymentTitleLabel: UILabel!
    @IBOutlet weak var totalPayableAmountLabel: UILabel!
    @IBOutlet weak var startLearningButton: UIButton!

    var paymentContext: PaymentCheckoutContext?
    var onPaymentSuccess: (() -> Void)?
    private var promoCodePrice: Double = 0
    private var currentTotalPayable: Double = 0
    private var appliedPromoCode: AppliedPromoCode?
    private var firstPaymentPlanAmount: Double = 0
    private var oneTimeEnrollmentPaymentPlanAmount: Double = 0
    private var firstPaymentPlanID: Int?
    private var oneTimeEnrollmentPaymentPlanID: Int?
    private var currentRazorpayOrderID: String?

    #if canImport(Razorpay)
    private var razorpay: RazorpayCheckout?
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        applyPaymentContext()
        fetchPlanPricing()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func applyButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        openPromoCodeScreen()
    }

    @IBAction func startLearningButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        startRazorpayCheckout()
    }

}

private extension PaymentSummaryViewController {
    func configureUI() {
        promoCodeTextField.delegate = self
        promoCodeTextField.clearButtonMode = .whileEditing
        promoCodeTextField.setLeftPaddingPoints(12)
        promoCodeTextField.setRightPaddingPoints(50)
        promoCodeTextField.layer.cornerRadius = promoCodeTextField.frame.height / 2
        promoCodeTextField.layer.masksToBounds = true
        applyButton.layer.cornerRadius = applyButton.frame.height / 2
        startLearningButton.layer.cornerRadius = startLearningButton.frame.height / 2

        headerLabel.font = UIFont.GilroyMedium(ofSize: 18)
        checkoutTitleLabel.font = UIFont.GilroyMedium(ofSize: 16)
        GrandTotalHeaderLabel.font = UIFont.GilroyMedium(ofSize: 16)
        promoCodeTitleLabel.font = UIFont.GilroyMedium(ofSize: 16)
        makePaymentTitleLabel.font = UIFont.GilroyMedium(ofSize: 16)
        tutionFeeLabel.font = UIFont.GilroyMedium(ofSize: 15)
        tutionFeeAmountLabel.font = UIFont.GilroyMedium(ofSize: 15)
        batchEnrollmentFeeLabel.font = UIFont.GilroyMedium(ofSize: 15)
        batchEnrollmentFeeAmountLabel.font = UIFont.GilroyMedium(ofSize: 15)
        subTotalLabel.font = UIFont.GilroyMedium(ofSize: 15)
        subTotalMonthsLabel.font = UIFont.GilroyMedium(ofSize: 15)
        subTotalAmountLabel.font = UIFont.GilroyMedium(ofSize: 15)
        grandTotalSubTotalLabel.font = UIFont.GilroyMedium(ofSize: 15)
        grandTotalSubTotalAmountLabel.font = UIFont.GilroyMedium(ofSize: 15)
        grandTotalOneTimePlatformFeeLabel.font = UIFont.GilroyMedium(ofSize: 15)
        grandTotalOneTimePlatformFeeAmountLabel.font = UIFont.GilroyMedium(ofSize: 15)
        grandTotalAmountLabel.font = UIFont.GilroyMedium(ofSize: 16)
        totalPayableAmountLabel.font = UIFont.GilroyMedium(ofSize: 16)
        applyButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 14)
        startLearningButton.titleLabel?.font = UIFont.GilroyMedium(ofSize: 16)
    }

    func applyPaymentContext() {
        guard let paymentContext else {
            return
        }

        let tuitionFee = PaymentCheckoutContext.displayAmount(paymentContext.tuitionFee)
        let enrollmentFee = PaymentCheckoutContext.displayAmount(firstPaymentPlanAmount)
        let oneTimeEnrollmentFee = PaymentCheckoutContext.displayAmount(oneTimeEnrollmentPaymentPlanAmount)

        checkoutTitleLabel.text = paymentContext.batchName
        tutionFeeAmountLabel.text = tuitionFee
        batchEnrollmentFeeAmountLabel.text = enrollmentFee
        grandTotalOneTimePlatformFeeAmountLabel.text = oneTimeEnrollmentFee
        recalculatePaymentTotals()
    }

    func fetchPlanPricing() {
        guard let batchID = paymentContext?.batchID else {
            return
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                let plans = try await PlanService.fetchPlans(batchID: batchID)
                let firstPaymentPlan = plans.first(where: { $0.normalizedPlanType == "FIRST_PAYMENT" })
                let oneTimeEnrollmentPlan = plans.first(where: { $0.normalizedPlanType == "RENEWAL" })

                await MainActor.run {
                    self.firstPaymentPlanID = firstPaymentPlan?.planID
                    self.oneTimeEnrollmentPaymentPlanID = oneTimeEnrollmentPlan?.planID
                    self.firstPaymentPlanAmount = firstPaymentPlan?.amount ?? 0
                    self.oneTimeEnrollmentPaymentPlanAmount = oneTimeEnrollmentPlan?.amount ?? 0
                    self.applyPaymentContext()
                }
            } catch {
                await MainActor.run {
                    self.showToastSafely(Self.errorMessage(from: error))
                }
            }
        }
    }

    func openPromoCodeScreen() {
        guard let paymentContext else {
            showToastSafely("Payment details are missing")
            return
        }

        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let promoCodeViewController = storyboard.instantiateViewController(
            withIdentifier: "PromoCodeViewController"
        ) as? PromoCodeViewController else {
            return
        }

        promoCodeViewController.paymentContext = paymentContext
        promoCodeViewController.appliedPromoCode = appliedPromoCode
        promoCodeViewController.enrollmentFeeAmount = firstPaymentPlanAmount + oneTimeEnrollmentPaymentPlanAmount
        promoCodeViewController.onPromoCodeApplied = { [weak self] promoCode in
            self?.applyPromoCode(promoCode)
        }
        promoCodeViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(promoCodeViewController, animated: true)
    }

    func recalculatePaymentTotals() {
        let breakdown = currentBreakdown()

        batchEnrollmentFeeAmountLabel.text = PaymentCheckoutContext.displayAmount(firstPaymentPlanAmount)
        grandTotalOneTimePlatformFeeAmountLabel.text = PaymentCheckoutContext.displayAmount(oneTimeEnrollmentPaymentPlanAmount)
        subTotalAmountLabel.text = PaymentCheckoutContext.displayAmount(breakdown.monthlySubtotal)
        subtotal12MonthsTotalLabel.text = PaymentCheckoutContext.displayAmount(breakdown.tuition12MonthTotal)
        grandTotalSubTotalAmountLabel.text = PaymentCheckoutContext.displayAmount(breakdown.tuition12MonthTotal)
        grandTotalAmountLabel.text = PaymentCheckoutContext.displayAmount(breakdown.grandTotalBeforeDiscount)
        totalPayableAmountLabel.text = PaymentCheckoutContext.displayAmount(breakdown.totalPayable)
        currentTotalPayable = breakdown.totalPayable
    }

    func applyPromoCode(_ promoCode: AppliedPromoCode) {
        appliedPromoCode = promoCode
        promoCodeTextField.text = promoCode.code
        promoCodePrice = promoCode.discountAmount
        recalculatePaymentTotals()
        showToastSafely("Promo code applied successfully")
    }

    func startRazorpayCheckout() {
        guard let paymentContext else {
            showToastSafely("Payment details are missing")
            return
        }

        guard currentTotalPayable > 0 else {
            showToastSafely("Invalid payable amount")
            return
        }

        printBackendCheckoutPayload()

        #if canImport(Razorpay)
        guard let batchID = paymentContext.batchID else {
            showToastSafely("Batch details are missing")
            return
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                try await self.refreshPaymentGatewayDefaultsIfNeeded()

                let orderResponse = try await RazorpayPaymentService.createOrder(
                    batchID: batchID,
                    amountInRupees: currentTotalPayable
                )

                guard let order = orderResponse.order else {
                    throw NetworkError.apiError("Payment order details are missing")
                }

                await MainActor.run {
                    let keyID = self.razorpayKeyID(from: orderResponse)
                    guard !keyID.isEmpty else {
                        self.showToastSafely("Payment gateway details are missing")
                        return
                    }

                    self.currentRazorpayOrderID = order.id
                    RazorpayCheckout.checkIntegration(withMerchantKey: keyID)
                    self.razorpay = RazorpayCheckout.initWithKey(keyID, andDelegateWithData: self)

                    let options: [String: Any] = [
                        "key": keyID,
                        "amount": order.amount,
                        "currency": order.currency,
                        "name": paymentContext.instituteName,
                        "description": paymentContext.displayDescription,
                        "order_id": order.id,
                        "prefill": [
                            "name": UserCache.fullName(),
                            "contact": self.formattedContactNumber(),
                            "email": UserCache.email_id()
                        ],
                        "theme": [
                            "color": "#0066FF"
                        ]
                    ]

                    print("Razorpay order created: \(order.id), amount: \(order.amount), currency: \(order.currency)")
                    self.razorpay?.open(options, displayController: self)
                }
            } catch {
                await MainActor.run {
                    self.showToastSafely(Self.errorMessage(from: error))
                }
            }
        }
        #else
        showToastSafely("Razorpay SDK is not linked")
        #endif
    }

    func refreshPaymentGatewayDefaultsIfNeeded() async throws {
        let cachedKeyID = UserCache.razorpayKeyID().trimmingCharacters(in: .whitespacesAndNewlines)
        guard cachedKeyID.isEmpty else { return }

        try await AppDefaultsService.fetchAndCacheRequirements()
    }

    func formattedContactNumber() -> String {
        let phone = UserCache.phone().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty else { return "" }

        let countryCode = UserCache.countryCode().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !countryCode.isEmpty else { return phone }

        return countryCode.hasPrefix("+") ? "\(countryCode)\(phone)" : "+\(countryCode)\(phone)"
    }

    func razorpayKeyID(from orderResponse: RazorpayCreateOrderResponse) -> String {
        let responseKeyID = orderResponse.keyID?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !responseKeyID.isEmpty {
            return responseKeyID
        }

        let cachedKeyID = UserCache.razorpayKeyID().trimmingCharacters(in: .whitespacesAndNewlines)
        if !cachedKeyID.isEmpty {
            return cachedKeyID
        }

        return paymentContext?.razorpayKeyID.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func printBackendCheckoutPayload() {
        guard let paymentContext else { return }

        let breakdown = currentBreakdown()

        print("""
        Backend checkout payload:
        student_id: \(resolvedStudentID().map(String.init) ?? "nil")
        batch_id: \(paymentContext.batchID.map(String.init) ?? "nil")
        first_payment_plan_id: \(firstPaymentPlanID.map(String.init) ?? "nil")
        renewal_plan_id: \(oneTimeEnrollmentPaymentPlanID.map(String.init) ?? "nil")
        promo_code_id: \(appliedPromoCode?.promoCodeID.description ?? "nil")
        promo_code: \(appliedPromoCode?.code ?? "nil")
        batch_price: \(paymentContext.batchPrice)
        batch_offer_price: \(paymentContext.batchOfferPrice?.description ?? "nil")
        tuition_fee: \(paymentContext.tuitionFee)
        first_payment_plan_amount: \(firstPaymentPlanAmount)
        renewal_plan_amount: \(oneTimeEnrollmentPaymentPlanAmount)
        monthly_subtotal: \(breakdown.monthlySubtotal)
        tuition_12_month_total: \(breakdown.tuition12MonthTotal)
        grand_total_before_discount: \(breakdown.grandTotalBeforeDiscount)
        discount_amount: \(breakdown.discountAmount)
        total_payable: \(breakdown.totalPayable)
        currency: \(paymentContext.currency)
        """)
    }

    func currentBreakdown() -> PaymentBreakdown {
        let tuitionFee = paymentContext?.tuitionFee ?? PaymentCheckoutContext.amount(from: tutionFeeAmountLabel.text)
        let monthlySubtotal = tuitionFee + firstPaymentPlanAmount
        let tuition12MonthTotal = monthlySubtotal * 12
        let grandTotalBeforeDiscount = tuition12MonthTotal + oneTimeEnrollmentPaymentPlanAmount
        let totalPayable = max(grandTotalBeforeDiscount - promoCodePrice, 0)

        return PaymentBreakdown(
            monthlySubtotal: monthlySubtotal,
            tuition12MonthTotal: tuition12MonthTotal,
            grandTotalBeforeDiscount: grandTotalBeforeDiscount,
            discountAmount: promoCodePrice,
            totalPayable: totalPayable
        )
    }

    func resolvedStudentID() -> Int? {
        let studentID = UserCache.studentID().trimmingCharacters(in: .whitespacesAndNewlines)
        if let id = Int(studentID), id > 0 {
            return id
        }

        let userID = UserCache.userID().trimmingCharacters(in: .whitespacesAndNewlines)
        if let id = Int(userID), id > 0 {
            return id
        }

        return nil
    }

    func verifyPayment(paymentID: String, response: [AnyHashable: Any]?) {
        guard let paymentContext else {
            showToastSafely("Payment details are missing")
            return
        }

        guard let studentID = resolvedStudentID(),
              let batchID = paymentContext.batchID,
              let firstPaymentPlanID,
              let oneTimeEnrollmentPaymentPlanID else {
            showToastSafely("Payment details are incomplete")
            return
        }

        let responseOrderID = response?[AnyHashable("razorpay_order_id")] as? String
        let responsePaymentID = response?[AnyHashable("razorpay_payment_id")] as? String
        let responseSignature = response?[AnyHashable("razorpay_signature")] as? String
        let razorpayPaymentID = responsePaymentID ?? paymentID

        guard let razorpayOrderID = responseOrderID ?? currentRazorpayOrderID,
              let razorpaySignature = responseSignature,
              !razorpayOrderID.isEmpty,
              !razorpayPaymentID.isEmpty,
              !razorpaySignature.isEmpty else {
            showToastSafely("Payment verification details are missing")
            return
        }

        let breakdown = currentBreakdown()
        let payload = RazorpayVerifyPaymentPayload(
            razorpayOrderID: razorpayOrderID,
            razorpayPaymentID: razorpayPaymentID,
            razorpaySignature: razorpaySignature,
            studentID: studentID,
            batchID: batchID,
            firstPaymentPlanID: firstPaymentPlanID,
            renewalPlanID: oneTimeEnrollmentPaymentPlanID,
            promoCodeID: appliedPromoCode?.promoCodeID,
            batchPrice: paymentContext.batchPrice,
            batchOfferPrice: paymentContext.batchOfferPrice,
            tuitionFee: paymentContext.tuitionFee,
            monthlySubtotal: breakdown.monthlySubtotal,
            tuition12MonthTotal: breakdown.tuition12MonthTotal,
            grandTotalBeforeDiscount: breakdown.grandTotalBeforeDiscount,
            discountAmount: breakdown.discountAmount,
            totalPayable: breakdown.totalPayable,
            currency: paymentContext.currency
        )

        Task { [weak self] in
            guard let self else { return }

            do {
                try await RazorpayPaymentService.verifyPayment(payload)
                await MainActor.run {
                    self.openPaymentSuccessScreen(paymentID: razorpayPaymentID)
                }
            } catch {
                await MainActor.run {
                    self.showToastSafely(Self.errorMessage(from: error))
                }
            }
        }
    }

    func openPaymentSuccessScreen(paymentID: String?) {
        onPaymentSuccess?()

        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let paymentSuccessViewController = storyboard.instantiateViewController(
            withIdentifier: "PaymentSuccessViewController"
        ) as? PaymentSuccessViewController else {
            return
        }

        paymentSuccessViewController.paymentID = paymentID
        paymentSuccessViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(paymentSuccessViewController, animated: true)
    }
}

private struct PaymentBreakdown {
    let monthlySubtotal: Double
    let tuition12MonthTotal: Double
    let grandTotalBeforeDiscount: Double
    let discountAmount: Double
    let totalPayable: Double
}

extension PaymentSummaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private extension PaymentSummaryViewController {
    static func errorMessage(from error: Error) -> String {
        switch error {
        case NetworkError.noInternetConnection:
            return "No internet connection"
        case NetworkError.apiError(let message),
             NetworkError.requestFailed(let message),
             NetworkError.decodingError(let message):
            return message
        case NetworkError.validation(let response):
            return response.error.first?.message ?? "Unable to process payment"
        default:
            return "Unable to process payment"
        }
    }
}

#if canImport(Razorpay)
extension PaymentSummaryViewController: RazorpayPaymentCompletionProtocolWithData {
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable: Any]?) {
        print("Razorpay payment success - payment_id: \(payment_id)")
        if let response {
            print("Razorpay success response: \(response)")
        }
        verifyPayment(paymentID: payment_id, response: response)
    }

    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable: Any]?) {
        print("Razorpay payment failure - code: \(code), description: \(str)")
        if let response {
            print("Razorpay failure response: \(response)")
        }
        showToastSafely(str.isEmpty ? "Payment failed. Please try again." : str)
    }
}
#endif

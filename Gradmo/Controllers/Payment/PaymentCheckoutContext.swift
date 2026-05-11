//
//  PaymentCheckoutContext.swift
//  Gradmo
//
//  Created by Codex on 19/04/26.
//

import Foundation

struct PaymentCheckoutContext {
    let batchID: Int?
    let instituteName: String
    let batchName: String
    let batchPrice: Double
    let batchOfferPrice: Double?
    let platformFee: Double
    let currency: String
    let razorpayKeyID: String
    let razorpayOrderID: String?

    var tuitionFee: Double {
        guard let batchOfferPrice, batchOfferPrice > 0 else {
            return batchPrice
        }

        return batchOfferPrice
    }

    var totalPayable: Double {
        tuitionFee + platformFee
    }

    var totalPayableSubunits: Int {
        Int((totalPayable * 100).rounded())
    }

    var displayDescription: String {
        "Enrollment for \(batchName)"
    }

    static func make(
        batchID: Int?,
        instituteName: String,
        batchName: String,
        batchPriceText: String?,
        batchOfferPriceText: String?
    ) -> PaymentCheckoutContext {
        PaymentCheckoutContext(
            batchID: batchID,
            instituteName: instituteName,
            batchName: batchName,
            batchPrice: Self.amount(from: batchPriceText),
            batchOfferPrice: Self.optionalAmount(from: batchOfferPriceText),
            platformFee: 499,
            currency: "INR",
            razorpayKeyID: Self.cachedRazorpayKeyID(),
            razorpayOrderID: nil
        )
    }

    private static func cachedRazorpayKeyID() -> String {
        let cachedKeyID = UserCache.razorpayKeyID().trimmingCharacters(in: .whitespacesAndNewlines)
        if !cachedKeyID.isEmpty {
            return cachedKeyID
        }

        return (Bundle.main.object(forInfoDictionaryKey: "RazorpayKeyID") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

struct PromoCodeListResponse: Decodable {
    let status: String
    let message: String?
    let msg: String?
    let data: PromoCodeListData?

    private enum CodingKeys: String, CodingKey {
        case status
        case message
        case msg
        case data
    }
}

struct PromoCodeListData: Decodable {
    let promoCodes: [PromoCode]
}

struct PromoCode: Decodable {
    let promoCodeID: Int
    let code: String
    let discountType: String
    let discountValue: Double
    let validFrom: String?
    let validTo: String?
    let maxUse: Int?
    let usedCount: Int?
    let status: Int?

    private enum CodingKeys: String, CodingKey {
        case promoCodeID = "promoCodeId"
        case code
        case discountType
        case discountValue
        case validFrom
        case validTo
        case maxUse
        case usedCount
        case status
    }

    var normalizedCode: String {
        code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var isActive: Bool {
        (status ?? 0) == 1
    }

    var isUsageAvailable: Bool {
        guard let maxUse else { return true }
        return (usedCount ?? 0) < maxUse
    }

    var isWithinValidityRange: Bool {
        let today = PromoCode.dateFormatter.string(from: Date())

        if let validFrom, !validFrom.isEmpty, validFrom > today {
            return false
        }

        if let validTo, !validTo.isEmpty, validTo < today {
            return false
        }

        return true
    }

    var isCurrentlyApplicable: Bool {
        isActive && isUsageAvailable && isWithinValidityRange
    }

    func discountAmount(for totalAmount: Double) -> Double {
        let normalizedType = discountType.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        switch normalizedType {
        case "PERCENT":
            return max((totalAmount * discountValue) / 100, 0)
        case "FLAT":
            return max(discountValue, 0)
        default:
            return 0
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct AppliedPromoCode {
    let promoCodeID: Int
    let code: String
    let discountAmount: Double
}

struct PlanListResponse: Decodable {
    let status: String
    let message: String?
    let msg: String?
    let data: PlanListData?
}

struct PlanListData: Decodable {
    let plans: [PlanItem]
}

struct PlanItem: Decodable {
    let planID: Int
    let planName: String?
    let planType: String?
    let amount: Double
    let validityDays: Int?
    let description: String?
    let status: Int?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case planID = "planId"
        case planName
        case planType
        case amount
        case validityDays
        case description
        case status
        case createdAt
    }

    var normalizedPlanType: String {
        planType?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
    }
}

enum PlanService {
    static func fetchPlans(batchID: Int) async throws -> [PlanItem] {
        let url = Constant.baseUrl + API.planListAPI
        let response: PlanListResponse = try await APIManager.shared.post(
            url,
            parameters: [APIKeys.batch_id: batchID],
            expectsWrappedResponse: false
        )

        let normalizedStatus = response.status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedStatus == "true" || normalizedStatus == "success" else {
            throw NetworkError.apiError(response.message ?? response.msg ?? "Unable to fetch plans")
        }

        return response.data?.plans ?? []
    }
}

struct RazorpayCreateOrderResponse: Decodable {
    let status: String
    let msg: String?
    let message: String?
    let order: RazorpayOrderPayload?
    let keyID: String?

    enum CodingKeys: String, CodingKey {
        case status
        case msg
        case message
        case order
        case keyID = "keyId"
    }
}

struct RazorpayOrderPayload: Decodable {
    let id: String
    let amount: Int
    let currency: String
    let receipt: String?
    let status: String?
}

struct RazorpayVerifyPaymentPayload {
    let razorpayOrderID: String
    let razorpayPaymentID: String
    let razorpaySignature: String
    let studentID: Int
    let batchID: Int
    let firstPaymentPlanID: Int
    let renewalPlanID: Int
    let promoCodeID: Int?
    let batchPrice: Double
    let batchOfferPrice: Double?
    let tuitionFee: Double
    let monthlySubtotal: Double
    let tuition12MonthTotal: Double
    let grandTotalBeforeDiscount: Double
    let discountAmount: Double
    let totalPayable: Double
    let currency: String

    var parameters: [String: Any] {
        var values: [String: Any] = [
            "razorpay_order_id": razorpayOrderID,
            "razorpay_payment_id": razorpayPaymentID,
            "razorpay_signature": razorpaySignature,
            "student_id": studentID,
            "batch_id": batchID,
            "first_payment_plan_id": firstPaymentPlanID,
            "renewal_plan_id": renewalPlanID,
            "batch_price": batchPrice,
            "tuition_fee": tuitionFee,
            "monthly_subtotal": monthlySubtotal,
            "tuition_12_month_total": tuition12MonthTotal,
            "grand_total_before_discount": grandTotalBeforeDiscount,
            "discount_amount": discountAmount,
            "total_payable": totalPayable,
            "currency": currency
        ]

        if let batchOfferPrice {
            values["batch_offer_price"] = batchOfferPrice
        }

        if let promoCodeID {
            values["promo_code_id"] = promoCodeID
        }

        return values
    }
}

struct RazorpayVerifyPaymentResponse: Decodable {
    let status: String
    let msg: String?
    let message: String?
}

enum RazorpayPaymentService {
    static func createOrder(batchID: Int, amountInRupees: Double) async throws -> RazorpayCreateOrderResponse {
        var components = URLComponents(string: Constant.baseUrl + API.razorpayCreateOrderAPI)
        components?.queryItems = [
            URLQueryItem(name: "amount_in_rupees", value: amountQueryValue(for: amountInRupees))
        ]

        guard let url = components?.url?.absoluteString else {
            throw NetworkError.invalidURL
        }

        let response: RazorpayCreateOrderResponse = try await APIManager.shared.post(
            url,
            parameters: [APIKeys.batch_id: batchID],
            expectsWrappedResponse: false
        )

        let normalizedStatus = response.status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedStatus == "true" || normalizedStatus == "success" else {
            throw NetworkError.apiError(response.msg ?? response.message ?? "Unable to create payment order")
        }

        guard response.order != nil, !(response.keyID ?? "").isEmpty else {
            throw NetworkError.apiError("Payment order details are missing")
        }

        return response
    }

    static func verifyPayment(_ payload: RazorpayVerifyPaymentPayload) async throws {
        let url = Constant.baseUrl + API.razorpayVerifyPaymentAPI
        let response: RazorpayVerifyPaymentResponse = try await APIManager.shared.post(
            url,
            parameters: payload.parameters,
            expectsWrappedResponse: false
        )

        let normalizedStatus = response.status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedStatus == "true" || normalizedStatus == "success" else {
            throw NetworkError.apiError(response.msg ?? response.message ?? "Unable to verify payment")
        }
    }

    private static func amountQueryValue(for amountInRupees: Double) -> String {
        if amountInRupees.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(amountInRupees))
        }

        return String(format: "%.2f", amountInRupees)
    }
}

enum PromoCodeService {
    static func fetchPromoCodes(batchID: Int) async throws -> [PromoCode] {
        let url = Constant.baseUrl + API.planPromoCodesAPI
        let response: PromoCodeListResponse = try await APIManager.shared.post(
            url,
            parameters: [APIKeys.batch_id: batchID],
            expectsWrappedResponse: false
        )

        let normalizedStatus = response.status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedStatus == "true" || normalizedStatus == "success" else {
            throw NetworkError.apiError(response.message ?? response.msg ?? "Unable to fetch promo codes")
        }

        return response.data?.promoCodes ?? []
    }
}

extension PaymentCheckoutContext {
    static func amount(from text: String?) -> Double {
        let cleanedText = (text ?? "")
            .filter { $0.isNumber || $0 == "." }

        return Double(cleanedText) ?? 0
    }

    static func optionalAmount(from text: String?) -> Double? {
        let amount = Self.amount(from: text)
        return amount > 0 ? amount : nil
    }

    static func displayAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = amount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: amount)) ?? "₹\(amount)"
    }
}

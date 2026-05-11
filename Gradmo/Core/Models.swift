//
//  Models.swift
//  Gradmo
//

import Foundation

private extension KeyedDecodingContainer {
    func decodeLossyStringIfPresent(forKey key: Key) throws -> String? {
        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return stringValue
        }

        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }

        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return String(doubleValue)
        }

        if let boolValue = try? decodeIfPresent(Bool.self, forKey: key) {
            return boolValue ? "true" : "false"
        }

        return nil
    }

    func decodeLossyIntIfPresent(forKey key: Key) throws -> Int? {
        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }

        if let stringValue = try? decodeIfPresent(String.self, forKey: key),
           let intValue = Int(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return intValue
        }

        return nil
    }

    func decodeLossyDoubleIfPresent(forKey key: Key) throws -> Double? {
        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return doubleValue
        }

        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return Double(intValue)
        }

        if let stringValue = try? decodeIfPresent(String.self, forKey: key),
           let doubleValue = Double(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return doubleValue
        }

        return nil
    }
}

// MARK: - UserRole

enum UserRole: String, CaseIterable {
    case student = "STUDENT"
    case teacher = "TEACHER"
    case institute = "INSTITUTE"

    var titleText: String {
        switch self {
        case .student:
            return "Student"
        case .teacher:
            return "Teacher"
        case .institute:
            return "Institute"
        }
    }

    init?(storageValue: String) {
        switch storageValue.uppercased() {
        case UserRole.student.rawValue:
            self = .student
        case UserRole.teacher.rawValue, "COUNSELOR":
            self = .teacher
        case UserRole.institute.rawValue, "PARENT":
            self = .institute
        default:
            return nil
        }
    }
}

// MARK: - AuthFlow Models

enum AuthFlowPurpose {
    case login
    case forgotPassword
    case signup
}

enum OTPDeliveryChannel {
    case phone
    case email

    var titleText: String {
        switch self {
        case .phone:
            return "Verify Phone"
        case .email:
            return "Verify Email"
        }
    }
}

enum OTPFlowDestination {
    case home
    case resetPassword
    case completeProfile
}

struct AuthUserData {
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var password: String = ""
    var studentId: String = ""
    var teacherId: String = ""
    var instituteId: String = ""
    var imageURL: String = ""
    var accessToken: String = ""
    var userRole: UserRole = .student
}

struct OTPFlowContext {
    var purpose: AuthFlowPurpose
    var channel: OTPDeliveryChannel
    var destination: OTPFlowDestination
    var recipient: String
    var userRole: UserRole
    var authUserData: AuthUserData?
}

// MARK: - CreateUserModel
struct CreateUserModel: Codable {
    var userID: String?
    var emailID: String?
    var isBlocked: Bool?
    var isVerified: Bool?
    var firstName: String?
    var lastName: String?
    var state: String?
    var city: String?
    var countryCode: String?
    var phoneNumber: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var roleID: String?

    enum CodingKeys: String, CodingKey {
        case userID       = "user_id"
        case emailID      = "email"
        case isBlocked    = "is_blocked"
        case isVerified   = "is_verified"
        case firstName    = "first_name"
        case lastName     = "last_name"
        case state
        case city
        case countryCode  = "country_code"
        case phoneNumber  = "phone_number"
        case address
        case latitude
        case longitude
        case roleID       = "role_id"
    }
}

// MARK: - Banner Slider Models

struct BannerSliderResponse: Decodable {
    let status: String
    let message: String?
    let data: BannerSliderData?
}

struct BannerSliderData: Decodable {
    let banners: [BannerSliderItem]
}

struct BannerSliderItem: Decodable {
    let id: Int?
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
    }
}

enum BannerSliderService {
    private static var cachedBanners: [BannerSliderItem] = []

    static func fetchBanners(forceReload: Bool = false) async throws -> [BannerSliderItem] {
        if !forceReload, !cachedBanners.isEmpty {
            return cachedBanners
        }

        let url = Constant.baseUrl + API.sliderListAPI
        let response: BannerSliderResponse = try await APIManager.shared.get(
            url,
            expectsWrappedResponse: false
        )

        let banners = response.data?.banners ?? []
        cachedBanners = banners
        return banners
    }
}

// MARK: - Institute Listing Models

struct InstituteListingRequest {
    var batchID: Int?
    var latitude: String?
    var longitude: String?
    var orderField: String?
    var orderType: String?
    var search: String?
    var city: String?

    var parameters: [String: Any] {
        var params: [String: Any] = [:]

        if let batchID {
            params[APIKeys.batch_id] = batchID
        }

        if let latitude = sanitized(latitude) {
            params[APIKeys.latitude] = latitude
        }

        if let longitude = sanitized(longitude) {
            params[APIKeys.longitude] = longitude
        }

        if let orderField = sanitized(orderField) {
            params[APIKeys.orderField] = orderField
        }

        if let orderType = sanitized(orderType) {
            params[APIKeys.orderType] = orderType
        }

        if let search = sanitized(search) {
            params[APIKeys.search] = search
        }

        if let city = sanitized(city) {
            params[APIKeys.city] = city
        }

        return params
    }

    private func sanitized(_ value: String?) -> String? {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

struct InstituteListingResponse: Decodable {
    let status: String
    let batchID: Int?
    let orderField: String?
    let orderType: String?
    let institutes: [InstituteListingItem]
    let pagination: InstituteListingPagination?
    let msg: String?
    let referenceLatitude: Double?
    let referenceLongitude: Double?

    enum CodingKeys: String, CodingKey {
        case status
        case batchID = "batchId"
        case orderField
        case orderType
        case institutes
        case pagination
        case msg
        case referenceLatitude
        case referenceLongitude
    }
}

struct InstituteListingItem: Decodable {
    let instituteID: Int
    let name: String
    let email: String?
    let mobile: String?
    let pincode: String?
    let country: String?
    let state: String?
    let city: String?
    let address: String?
    let schoolCollegeName: String?
    let teachEducation: String?
    let instituteCode: String?
    let role: Int?
    let userType: String?
    let image: String?
    let imageURL: String?
    let instituteLatitude: Double?
    let instituteLongitude: Double?
    let distanceKM: Double?
    let averageRating: Double?
    let totalReviews: Int?

    enum CodingKeys: String, CodingKey {
        case instituteID = "instituteId"
        case name
        case email
        case mobile
        case pincode
        case country
        case state
        case city
        case address
        case schoolCollegeName
        case teachEducation
        case instituteCode
        case role
        case userType
        case image
        case imageURL = "imageUrl"
        case instituteLatitude
        case instituteLongitude
        case distanceKM = "distanceKm"
        case averageRating
        case totalReviews
        case reviewCount
        case rating
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instituteID = try container.decodeLossyIntIfPresent(forKey: .instituteID) ?? 0
        name = try container.decodeLossyStringIfPresent(forKey: .name) ?? ""
        email = try container.decodeLossyStringIfPresent(forKey: .email)
        mobile = try container.decodeLossyStringIfPresent(forKey: .mobile)
        pincode = try container.decodeLossyStringIfPresent(forKey: .pincode)
        country = try container.decodeLossyStringIfPresent(forKey: .country)
        state = try container.decodeLossyStringIfPresent(forKey: .state)
        city = try container.decodeLossyStringIfPresent(forKey: .city)
        address = try container.decodeLossyStringIfPresent(forKey: .address)
        schoolCollegeName = try container.decodeLossyStringIfPresent(forKey: .schoolCollegeName)
        teachEducation = try container.decodeLossyStringIfPresent(forKey: .teachEducation)
        instituteCode = try container.decodeLossyStringIfPresent(forKey: .instituteCode)
        role = try container.decodeLossyIntIfPresent(forKey: .role)
        userType = try container.decodeLossyStringIfPresent(forKey: .userType)
        image = try container.decodeLossyStringIfPresent(forKey: .image)
        imageURL = try container.decodeLossyStringIfPresent(forKey: .imageURL)
        instituteLatitude = try container.decodeLossyDoubleIfPresent(forKey: .instituteLatitude)
        instituteLongitude = try container.decodeLossyDoubleIfPresent(forKey: .instituteLongitude)
        distanceKM = try container.decodeLossyDoubleIfPresent(forKey: .distanceKM)

        let ratingSummary: InstituteDetailsRating?
        do {
            ratingSummary = try container.decodeIfPresent(InstituteDetailsRating.self, forKey: .rating)
        } catch {
            ratingSummary = nil
        }

        if let ratingValue = ratingSummary?.averageRating {
            averageRating = ratingValue
        } else if let ratingValue = try container.decodeLossyDoubleIfPresent(forKey: .averageRating) {
            averageRating = ratingValue
        } else {
            averageRating = try container.decodeLossyDoubleIfPresent(forKey: .rating)
        }

        if let reviewCount = ratingSummary?.totalReviews {
            totalReviews = reviewCount
        } else if let reviewCount = try container.decodeLossyIntIfPresent(forKey: .totalReviews) {
            totalReviews = reviewCount
        } else {
            totalReviews = try container.decodeLossyIntIfPresent(forKey: .reviewCount)
        }
    }

    var formattedAddress: String {
        let parts = [
            address,
            city,
            state,
            country,
            pincode
        ]
        .compactMap { value -> String? in
            let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return trimmedValue.isEmpty ? nil : trimmedValue
        }

        return parts.isEmpty ? "Address not available" : parts.joined(separator: ", ")
    }

    var displayID: String {
        if let instituteCode, !instituteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return instituteCode
        }

        return "ID: \(instituteID)"
    }

    var displayRating: String {
        guard let averageRating else {
            return "N/A"
        }

        if let totalReviews {
            return String(format: "%.1f(%d)", averageRating, totalReviews)
        }

        return String(format: "%.1f", averageRating)
    }

    var supportsOnline: Bool {
        true
    }

    var supportsOffline: Bool {
        true
    }

    var supportsHybrid: Bool {
        false
    }
}

struct InstituteListingPagination: Decodable {
    let page: Int?
    let limit: Int?
    let totalRecords: Int?
    let totalPages: Int?
    let total: Int?
}

enum InstituteListingService {
    static func fetchInstitutes(request: InstituteListingRequest) async throws -> InstituteListingResponse {
        let url = Constant.baseUrl + API.instituteListingAPI
        return try await APIManager.shared.post(
            url,
            parameters: request.parameters,
            expectsWrappedResponse: false
        )
    }
}

struct InstituteCityListResponse: Decodable {
    let status: String
    let cities: [InstituteCityItem]
    let msg: String?

    enum CodingKeys: String, CodingKey {
        case status
        case cities
        case msg
    }

    var isSuccess: Bool {
        status.lowercased() == "true"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeLossyStringIfPresent(forKey: .status) ?? "false"
        cities = try container.decodeIfPresent([InstituteCityItem].self, forKey: .cities) ?? []
        msg = try container.decodeLossyStringIfPresent(forKey: .msg)
    }
}

struct InstituteCityItem: Decodable {
    let city: String

    enum CodingKeys: String, CodingKey {
        case city
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        city = try container.decodeLossyStringIfPresent(forKey: .city) ?? ""
    }
}

enum InstituteCityListService {
    static func fetchCities() async throws -> InstituteCityListResponse {
        let url = Constant.baseUrl + API.instituteCityListAPI
        return try await APIManager.shared.post(
            url,
            expectsWrappedResponse: false
        )
    }
}

// MARK: - Institute Details Models

struct InstituteDetailsResponse: Decodable {
    let status: String
    let institute: InstituteDetailsInstitute?
    let batches: [InstituteDetailsBatch]
    let rating: InstituteDetailsRating?
    let reviews: [InstituteDetailsReview]
    let msg: String?

    enum CodingKeys: String, CodingKey {
        case status
        case institute
        case batches
        case rating
        case reviews
        case msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeLossyStringIfPresent(forKey: .status) ?? ""
        institute = try container.decodeIfPresent(InstituteDetailsInstitute.self, forKey: .institute)
        batches = try container.decodeIfPresent([InstituteDetailsBatch].self, forKey: .batches) ?? []
        rating = try container.decodeIfPresent(InstituteDetailsRating.self, forKey: .rating)
        reviews = try container.decodeIfPresent([InstituteDetailsReview].self, forKey: .reviews) ?? []
        msg = try container.decodeLossyStringIfPresent(forKey: .msg)
    }
}

struct InstituteDetailsInstitute: Decodable {
    let instituteID: Int?
    let name: String?
    let email: String?
    let mobile: String?
    let pincode: String?
    let role: Int?
    let userType: String?
    let image: String?
    let imageURL: String?
    let updatedAt: String?
    let teachEducation: String?
    let teachGender: String?
    let parentID: Int?

    enum CodingKeys: String, CodingKey {
        case instituteID = "instituteId"
        case name
        case email
        case mobile
        case pincode
        case role
        case userType
        case image
        case imageURL = "imageUrl"
        case updatedAt
        case teachEducation
        case teachGender
        case parentID = "parentId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instituteID = try container.decodeLossyIntIfPresent(forKey: .instituteID)
        name = try container.decodeLossyStringIfPresent(forKey: .name)
        email = try container.decodeLossyStringIfPresent(forKey: .email)
        mobile = try container.decodeLossyStringIfPresent(forKey: .mobile)
        pincode = try container.decodeLossyStringIfPresent(forKey: .pincode)
        role = try container.decodeLossyIntIfPresent(forKey: .role)
        userType = try container.decodeLossyStringIfPresent(forKey: .userType)
        image = try container.decodeLossyStringIfPresent(forKey: .image)
        imageURL = try container.decodeLossyStringIfPresent(forKey: .imageURL)
        updatedAt = try container.decodeLossyStringIfPresent(forKey: .updatedAt)
        teachEducation = try container.decodeLossyStringIfPresent(forKey: .teachEducation)
        teachGender = try container.decodeLossyStringIfPresent(forKey: .teachGender)
        parentID = try container.decodeLossyIntIfPresent(forKey: .parentID)
    }
}

private enum BatchScheduleFormatter {
    private static let outputDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy h:mm a"
        return formatter
    }()

    private static let outputTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private static let inputDateTimeFormats = [
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd HH:mm",
        "yyyy-MM-dd h:mm a",
        "yyyy-MM-dd h:mm:ss a",
        "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
        "yyyy-MM-dd'T'HH:mm:ssXXXXX",
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
        "dd/MM/yyyy HH:mm:ss",
        "dd/MM/yyyy HH:mm",
        "dd/MM/yyyy h:mm a",
        "dd/MM/yyyy h:mm:ss a",
        "dd-MM-yyyy HH:mm:ss",
        "dd-MM-yyyy HH:mm",
        "dd-MM-yyyy h:mm a",
        "dd-MM-yyyy h:mm:ss a",
        "MM/dd/yyyy HH:mm:ss",
        "MM/dd/yyyy HH:mm",
        "MM/dd/yyyy h:mm a",
        "MM/dd/yyyy h:mm:ss a"
    ]

    private static let inputDateFormats = [
        "yyyy-MM-dd",
        "dd/MM/yyyy",
        "dd-MM-yyyy",
        "MM/dd/yyyy"
    ]

    private static let inputTimeFormats = [
        "HH:mm:ss.SSS",
        "HH:mm:ss",
        "HH:mm",
        "h:mm a",
        "h:mm:ss a",
        "ha",
        "h a"
    ]

    static func displayRange(startDate: String?, startTime: String?, endDate: String?, endTime: String?) -> String {
        let start = displayDateTime(date: startDate, time: startTime)
        let end = displayTimeOnly(time: endTime)

        if let start, let end {
            return "\(start) - \(end)"
        }

        if let start {
            return start
        }

        if let end {
            return end
        }

        return "Not available"
    }

    static func displayDateTimeText(_ value: String?) -> String? {
        guard let text = sanitized(value) else {
            return nil
        }

        let normalizedText = normalizedMeridiem(text)
        if let date = parseDateTime(normalizedText) {
            return outputDateTimeFormatter.string(from: date)
        }

        if let date = parseDate(normalizedText) {
            return dateOnlyFormatter.string(from: date)
        }

        if let date = parseTime(normalizedText) {
            return outputTimeFormatter.string(from: date)
        }

        return text
    }

    private static func displayTimeOnly(time: String?) -> String? {
        guard let timeText = sanitized(time) else {
            return nil
        }

        return displayTime(timeText)
    }

    private static func displayDateTime(date: String?, time: String?) -> String? {
        let dateText = sanitized(date)
        let timeText = sanitized(time)

        if let dateText, let timeText {
            let combinedText = "\(dateText) \(normalizedMeridiem(timeText))"
            if let date = parseDateTime(combinedText) {
                return outputDateTimeFormatter.string(from: date)
            }

            if let datePart = datePortion(from: dateText) {
                let combinedDatePartText = "\(datePart) \(normalizedMeridiem(timeText))"
                if let date = parseDateTime(combinedDatePartText) {
                    return outputDateTimeFormatter.string(from: date)
                }
            }
        }

        if let dateText, let date = parseDateTime(dateText) {
            return outputDateTimeFormatter.string(from: date)
        }

        if let dateText, let parsedDate = parseDate(dateText) {
            let datePart = dateOnlyFormatter.string(from: parsedDate)
            if let timeText {
                return "\(datePart) \(displayTime(timeText))"
            }

            return datePart
        }

        if let timeText {
            return displayTime(timeText)
        }

        return nil
    }

    private static var dateOnlyFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }

    private static func displayTime(_ text: String) -> String {
        let normalizedText = normalizedMeridiem(text)
        guard let date = parseTime(normalizedText) else {
            return text
        }

        return outputTimeFormatter.string(from: date)
    }

    private static func parseDateTime(_ text: String) -> Date? {
        parse(text, formats: inputDateTimeFormats)
    }

    private static func parseDate(_ text: String) -> Date? {
        parse(text, formats: inputDateFormats)
    }

    private static func parseTime(_ text: String) -> Date? {
        parse(text, formats: inputTimeFormats)
    }

    private static func parse(_ text: String, formats: [String]) -> Date? {
        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = format

            if let date = formatter.date(from: text) {
                return date
            }
        }

        return nil
    }

    private static func sanitized(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }

    private static func normalizedMeridiem(_ value: String) -> String {
        let uppercasedMeridiem = value
            .replacingOccurrences(of: "am", with: "AM", options: .caseInsensitive)
            .replacingOccurrences(of: "pm", with: "PM", options: .caseInsensitive)

        return uppercasedMeridiem
            .replacingOccurrences(of: #"(\d)(AM|PM)"#, with: "$1 $2", options: .regularExpression)
    }

    private static func datePortion(from value: String) -> String? {
        if let separatorIndex = value.firstIndex(of: "T") {
            return String(value[..<separatorIndex])
        }

        let parts = value.split(separator: " ")
        if parts.count > 1 {
            return String(parts[0])
        }

        return nil
    }
}

struct InstituteDetailsBatch: Decodable {
    let id: Int?
    let adminID: Int?
    let categoryID: Int?
    let subcategoryID: Int?
    let batchName: String?
    let instituteID: Int?
    let batchMode: String?
    let startDate: String?
    let endDate: String?
    let startTime: String?
    let endTime: String?
    let batchType: Int?
    let batchPrice: String?
    let batchOfferPrice: String?
    let description: String?
    let batchImage: String?
    let numberOfStudents: Int?
    let status: Int?
    let payMode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case adminID = "admin_id"
        case categoryID = "cat_id"
        case subcategoryID = "sub_cat_id"
        case batchName = "batch_name"
        case instituteID = "institute_id"
        case batchMode = "batch_mode"
        case startDate = "start_date"
        case endDate = "end_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case batchType = "batch_type"
        case batchPrice = "batch_price"
        case batchOfferPrice = "batch_offer_price"
        case description
        case batchImage = "batch_image"
        case numberOfStudents = "no_of_student"
        case status
        case payMode = "pay_mode"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyIntIfPresent(forKey: .id)
        adminID = try container.decodeLossyIntIfPresent(forKey: .adminID)
        categoryID = try container.decodeLossyIntIfPresent(forKey: .categoryID)
        subcategoryID = try container.decodeLossyIntIfPresent(forKey: .subcategoryID)
        batchName = try container.decodeLossyStringIfPresent(forKey: .batchName)
        instituteID = try container.decodeLossyIntIfPresent(forKey: .instituteID)
        batchMode = try container.decodeLossyStringIfPresent(forKey: .batchMode)
        startDate = try container.decodeLossyStringIfPresent(forKey: .startDate)
        endDate = try container.decodeLossyStringIfPresent(forKey: .endDate)
        startTime = try container.decodeLossyStringIfPresent(forKey: .startTime)
        endTime = try container.decodeLossyStringIfPresent(forKey: .endTime)
        batchType = try container.decodeLossyIntIfPresent(forKey: .batchType)
        batchPrice = try container.decodeLossyStringIfPresent(forKey: .batchPrice)
        batchOfferPrice = try container.decodeLossyStringIfPresent(forKey: .batchOfferPrice)
        description = try container.decodeLossyStringIfPresent(forKey: .description)
        batchImage = try container.decodeLossyStringIfPresent(forKey: .batchImage)
        numberOfStudents = try container.decodeLossyIntIfPresent(forKey: .numberOfStudents)
        status = try container.decodeLossyIntIfPresent(forKey: .status)
        payMode = try container.decodeLossyStringIfPresent(forKey: .payMode)
    }

    var displayImageURL: String? {
        guard let image = batchImage?.trimmingCharacters(in: .whitespacesAndNewlines), !image.isEmpty else {
            return nil
        }

        if image.lowercased().hasPrefix("http") {
            return image
        }

        return Constant.baseUrl + "uploads/batch_image/" + image
    }

    var displayTiming: String {
        BatchScheduleFormatter.displayRange(
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime
        )
    }
}

struct InstituteDetailsRating: Decodable {
    let averageRating: Double?
    let totalReviews: Int?

    enum CodingKeys: String, CodingKey {
        case averageRating
        case totalReviews
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        averageRating = try container.decodeLossyDoubleIfPresent(forKey: .averageRating)
        totalReviews = try container.decodeLossyIntIfPresent(forKey: .totalReviews)
    }
}

struct InstituteDetailsReview: Decodable {
    let id: Int?
    let userID: Int?
    let userType: String?
    let instituteID: Int?
    let rating: Double?
    let msg: String?
    let approvedBy: Int?
    let status: Int?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case userType
        case instituteID = "instituteId"
        case rating
        case msg
        case approvedBy
        case status
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyIntIfPresent(forKey: .id)
        userID = try container.decodeLossyIntIfPresent(forKey: .userID)
        userType = try container.decodeLossyStringIfPresent(forKey: .userType)
        instituteID = try container.decodeLossyIntIfPresent(forKey: .instituteID)
        rating = try container.decodeLossyDoubleIfPresent(forKey: .rating)
        msg = try container.decodeLossyStringIfPresent(forKey: .msg)
        approvedBy = try container.decodeLossyIntIfPresent(forKey: .approvedBy)
        status = try container.decodeLossyIntIfPresent(forKey: .status)
        createdAt = try container.decodeLossyStringIfPresent(forKey: .createdAt)
    }
}

extension InstituteDetailsReview {
    var displayCreatedAt: String {
        BatchScheduleFormatter.displayDateTimeText(createdAt) ?? ""
    }
}

enum InstituteDetailsService {
    static func fetchInstituteDetails(instituteID: Int) async throws -> InstituteDetailsResponse {
        let url = Constant.baseUrl + API.instituteDetailsAPI
        return try await APIManager.shared.post(
            url,
            parameters: [APIKeys.institute_id: instituteID],
            expectsWrappedResponse: false
        )
    }
}

// MARK: - Batch List Models

struct BatchListResponse: Decodable {
    let status: String
    let message: String?
    let msg: String?
    let data: BatchListData?
}

struct BatchListData: Decodable {
    let enrolledBatches: [EnrolledBatchItem]
    let pagination: InstituteListingPagination?

    enum CodingKeys: String, CodingKey {
        case enrolledBatches = "enrolled_batches"
        case pagination
    }
}

struct EnrolledBatchItem: Decodable {
    let batchID: Int
    let title: String?
    let batchName: String?
    let instructor: String?
    let schedule: String?
    let startTime: String?
    let endTime: String?
    let startDate: String?
    let endDate: String?
    let logo: String?
    let batchImage: String?
    let batchType: Int?
    let description: String?
    let enrollmentStatus: Int?
    let enrolledAt: String?

    enum CodingKeys: String, CodingKey {
        case batchID = "batch_id"
        case title
        case batchName
        case instructor
        case schedule
        case startTime = "start_time"
        case endTime = "end_time"
        case startDate = "start_date"
        case endDate = "end_date"
        case logo
        case batchImage
        case batchType = "batch_type"
        case description
        case enrollmentStatus = "enrollment_status"
        case enrolledAt = "enrolled_at"
    }
}

extension EnrolledBatchItem {
    var displayTiming: String {
        let formattedTiming = BatchScheduleFormatter.displayRange(
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime
        )

        if formattedTiming != "Not available" {
            return formattedTiming
        }

        return schedule?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? schedule!
            : "Not available"
    }
}

enum BatchListService {
    static func fetchEnrolledBatches(parameters: [String: Any]? = nil) async throws -> BatchListResponse {
        let url = Constant.baseUrl + API.batchListAPI
        if let parameters {
            return try await APIManager.shared.post(
                url,
                parameters: parameters,
                expectsWrappedResponse: false
            )
        }

        return try await APIManager.shared.post(url, expectsWrappedResponse: false)
    }
}

// MARK: - Batch Details Models

struct BatchDetailsResponse: Decodable {
    let status: String
    let message: String?
    let msg: String?
    let batchDetails: BatchDetailsItem?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case msg
        case batchDetails = "batch_details"
    }
}

struct BatchDetailsItem: Decodable {
    let batchID: Int
    let title: String?
    let batchName: String?
    let instructor: String?
    let schedule: String?
    let startTime: String?
    let endTime: String?
    let startDate: String?
    let endDate: String?
    let logo: String?
    let batchImage: String?
    let description: String?
    let batchType: Int?
    let batchPrice: String?
    let batchOfferPrice: String?
    let payMode: String?
    let categoryName: String?
    let subcategoryName: String?
    let batchFecherd: [BatchFeatureItem]?
    let enrollment: BatchEnrollmentDetails?
    let modules: BatchModuleSummary?

    enum CodingKeys: String, CodingKey {
        case batchID = "batch_id"
        case title
        case batchName
        case instructor
        case schedule
        case startTime = "start_time"
        case endTime = "end_time"
        case startDate = "start_date"
        case endDate = "end_date"
        case logo
        case batchImage
        case description
        case batchType = "batch_type"
        case batchPrice = "batch_price"
        case batchOfferPrice = "batch_offer_price"
        case payMode = "pay_mode"
        case categoryName = "category_name"
        case subcategoryName = "subcategory_name"
        case batchFecherd
        case enrollment
        case modules
    }
}

extension BatchDetailsItem {
    var displayTiming: String {
        let formattedTiming = BatchScheduleFormatter.displayRange(
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime
        )

        if formattedTiming != "Not available" {
            return formattedTiming
        }

        return schedule?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? schedule!
            : "Not available"
    }
}

struct BatchFeatureItem: Decodable {
    let batchSpecification: String?
    let fecherd: String?
}

struct BatchEnrollmentDetails: Decodable {
    let status: Int?
    let createdAt: String?
    let addedBy: String?

    enum CodingKeys: String, CodingKey {
        case status
        case createdAt = "create_at"
        case addedBy = "added_by"
    }
}

struct BatchModuleSummary: Decodable {
    let liveClasses: BatchModuleStatus?
    let videoLectures: BatchCountModule?
    let library: BatchLibraryModule?
    let attendance: BatchCountModule?
    let upcomingExams: BatchCountModule?
    let homework: BatchHomeworkModule?

    enum CodingKeys: String, CodingKey {
        case liveClasses = "live_classes"
        case videoLectures = "video_lectures"
        case library
        case attendance
        case upcomingExams = "upcoming_exams"
        case homework
    }
}

struct BatchModuleStatus: Decodable {
    let isLive: Bool?
    let currentSessionID: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case isLive = "is_live"
        case currentSessionID = "current_session_id"
        case icon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let boolValue = try? container.decodeIfPresent(Bool.self, forKey: .isLive) {
            isLive = boolValue
        } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: .isLive) {
            isLive = intValue == 1
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .isLive) {
            let normalizedValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            isLive = normalizedValue == "1" || normalizedValue == "true"
        } else {
            isLive = nil
        }

        currentSessionID = try container.decodeIfPresent(String.self, forKey: .currentSessionID)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
    }
}

struct BatchCountModule: Decodable {
    let count: Int?
    let markedRecords: Int?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case count
        case markedRecords = "marked_records"
        case icon
    }
}

struct BatchLibraryModule: Decodable {
    let bookCount: Int?
    let notesCount: Int?
    let hasNewContent: Bool?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case bookCount = "book_count"
        case notesCount = "notes_count"
        case hasNewContent = "has_new_content"
        case icon
    }
}

struct BatchHomeworkModule: Decodable {
    let todayCount: Int?
    let pendingCount: Int?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case todayCount = "today_count"
        case pendingCount = "pending_count"
        case icon
    }
}

enum BatchDetailsService {
    static func fetchBatchDetails(batchID: Int) async throws -> BatchDetailsResponse {
        let url = Constant.baseUrl + API.batchDetailsAPI
        return try await APIManager.shared.post(
            url,
            parameters: [APIKeys.batch_id: batchID],
            expectsWrappedResponse: false
        )
    }
}

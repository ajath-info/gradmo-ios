//
//  CompleteProfileModels.swift
//  Gradmo
//

import Foundation

struct LocationCountry: Decodable {
    let id: Int
    let countryCode: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id
        case countryCode
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyInt(forKey: .id)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}

struct LocationState: Decodable {
    let id: Int
    let name: String
    let countryId: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyInt(forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        countryId = try container.decodeLossyIntIfPresent(forKey: .countryId)
    }
}

struct LocationCity: Decodable {
    let id: Int
    let city: String
    let stateId: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case city
        case stateId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyInt(forKey: .id)
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        stateId = try container.decodeLossyIntIfPresent(forKey: .stateId)
    }
}

struct CountryListResponse: Decodable {
    let status: String
    let countries: [LocationCountry]
    let msg: String?

    var isSuccess: Bool {
        status.lowercased() == "true"
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case countries
        case msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeLossyStatus(forKey: .status)
        countries = try container.decodeIfPresent([LocationCountry].self, forKey: .countries) ?? []
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
    }
}

struct StateListRequest {
    let countryId: Int

    func toParameters() -> [String: Any] {
        ["country_id": String(countryId)]
    }
}

struct StateListResponse: Decodable {
    let status: String
    let countryId: Int?
    let states: [LocationState]
    let msg: String?

    var isSuccess: Bool {
        status.lowercased() == "true"
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case countryId
        case states
        case msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeLossyStatus(forKey: .status)
        countryId = try container.decodeLossyIntIfPresent(forKey: .countryId)
        states = try container.decodeIfPresent([LocationState].self, forKey: .states) ?? []
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
    }
}

struct CityListRequest {
    let stateId: Int

    func toParameters() -> [String: Any] {
        ["state_id": String(stateId)]
    }
}

struct CityListResponse: Decodable {
    let status: String
    let stateId: Int?
    let cities: [LocationCity]
    let msg: String?

    var isSuccess: Bool {
        status.lowercased() == "true"
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case stateId
        case cities
        case msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeLossyStatus(forKey: .status)
        stateId = try container.decodeLossyIntIfPresent(forKey: .stateId)
        cities = try container.decodeIfPresent([LocationCity].self, forKey: .cities) ?? []
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
    }
}

struct CompleteProfileUpdateProfileRequest {
    let name: String
    let email: String
    let mobile: String
    let userType: String
    let address: String
    let latitude: String
    let longitude: String
    let country: String
    let state: String
    let city: String
    let imageURL: String
    let pincode: String
    let schoolCollegeName: String
    let grade: String
    let studentId: String
    let teacherId: String
    let instituteId: String
    let isProfileCompleted: String

    func toParameters() -> [String: String] {
        var parameters: [String: String] = [
            APIKeys.name: name,
            "email": email,
            APIKeys.mobile: mobile,
            APIKeys.userType: userType,
            APIKeys.address: address,
            APIKeys.latitude: latitude,
            APIKeys.longitude: longitude,
            APIKeys.country: country,
            APIKeys.state: state,
            APIKeys.city: city,
            APIKeys.image: imageURL,
            APIKeys.pincode: pincode,
            "school_college_name": schoolCollegeName,
            "grade": grade,
            "is_profile_completed": isProfileCompleted
        ]

        if !studentId.isEmpty {
            parameters["student_id"] = studentId
        }
        if !teacherId.isEmpty {
            parameters["teacher_id"] = teacherId
        }
        if !instituteId.isEmpty {
            parameters["institute_id"] = instituteId
        }

        return parameters
    }
}

struct CompleteProfileUpdateProfileResponse: Decodable {
    let status: String
    let msg: String?
    let data: CompleteProfileUpdatedUserData?

    var isSuccess: Bool {
        status.lowercased() == "true"
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case msg
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        data = try container.decodeIfPresent(CompleteProfileUpdatedUserData.self, forKey: .data)

        if let statusString = try? container.decodeIfPresent(String.self, forKey: .status) {
            status = statusString
        } else if let statusBool = try? container.decodeIfPresent(Bool.self, forKey: .status) {
            status = statusBool ? "true" : "false"
        } else {
            status = "false"
        }
    }
}

struct CompleteProfileUpdatedUserData: Decodable {
    let id: String?
    let studentId: Int?
    let teacherId: Int?
    let instituteId: Int?
    let adminId: String?
    let name: String?
    let enrollmentId: String?
    let image: String?
    let email: String?
    let contactNo: String?
    let mobile: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let pincode: String?
    let country: String?
    let state: String?
    let city: String?
    let schoolCollegeName: String?
    let grade: String?
    let deviceId: String?
    let deviceToken: String?
    let deviceType: String?
    let userType: String?
    let isProfileCompleted: String?

    enum CodingKeys: String, CodingKey {
        case id
        case studentId
        case teacherId
        case instituteId
        case adminId = "admin_id"
        case adminIdCamel = "adminId"
        case name
        case enrollmentId = "enrollment_id"
        case enrollmentIdCamel = "enrollmentId"
        case image
        case email
        case contactNo = "contact_no"
        case contactNoCamel = "contactNo"
        case mobile
        case address
        case latitude
        case longitude
        case pincode
        case country
        case state
        case city
        case schoolCollegeName = "school_college_name"
        case schoolCollegeNameCamel = "schoolCollegeName"
        case grade
        case deviceId = "device_id"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case userType = "user_type"
        case userTypeCamel = "userType"
        case isProfileCompleted = "is_profile_completed"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        studentId = try container.decodeLossyIntIfPresent(forKey: .studentId)
        teacherId = try container.decodeLossyIntIfPresent(forKey: .teacherId)
        instituteId = try container.decodeLossyIntIfPresent(forKey: .instituteId)

        id = try container.decodeLossyStringIfPresent(forKey: .id)
            ?? studentId.map(String.init)
            ?? teacherId.map(String.init)
            ?? instituteId.map(String.init)
        adminId = try container.decodeLossyStringIfPresent(forKey: .adminId)
            ?? container.decodeLossyStringIfPresent(forKey: .adminIdCamel)
        name = try container.decodeLossyStringIfPresent(forKey: .name)
        enrollmentId = try container.decodeLossyStringIfPresent(forKey: .enrollmentId)
            ?? container.decodeLossyStringIfPresent(forKey: .enrollmentIdCamel)
        image = try container.decodeLossyStringIfPresent(forKey: .image)
        email = try container.decodeLossyStringIfPresent(forKey: .email)
        contactNo = try container.decodeLossyStringIfPresent(forKey: .contactNo)
            ?? container.decodeLossyStringIfPresent(forKey: .contactNoCamel)
        mobile = try container.decodeLossyStringIfPresent(forKey: .mobile)
        address = try container.decodeLossyStringIfPresent(forKey: .address)
        latitude = try container.decodeLossyDoubleIfPresent(forKey: .latitude)
        longitude = try container.decodeLossyDoubleIfPresent(forKey: .longitude)
        pincode = try container.decodeLossyStringIfPresent(forKey: .pincode)
        country = try container.decodeLossyStringIfPresent(forKey: .country)
        state = try container.decodeLossyStringIfPresent(forKey: .state)
        city = try container.decodeLossyStringIfPresent(forKey: .city)
        schoolCollegeName = try container.decodeLossyStringIfPresent(forKey: .schoolCollegeName)
            ?? container.decodeLossyStringIfPresent(forKey: .schoolCollegeNameCamel)
        grade = try container.decodeLossyStringIfPresent(forKey: .grade)
        deviceId = try container.decodeLossyStringIfPresent(forKey: .deviceId)
        deviceToken = try container.decodeLossyStringIfPresent(forKey: .deviceToken)
        deviceType = try container.decodeLossyStringIfPresent(forKey: .deviceType)
        userType = try container.decodeLossyStringIfPresent(forKey: .userType)
            ?? container.decodeLossyStringIfPresent(forKey: .userTypeCamel)
        isProfileCompleted = try container.decodeLossyStringIfPresent(forKey: .isProfileCompleted)
    }
}

private extension KeyedDecodingContainer {
    func decodeLossyStringIfPresent(forKey key: Key) throws -> String? {
        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return normalizedNullableString(stringValue)
        }

        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }

        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return String(Int(doubleValue))
        }

        if let boolValue = try? decodeIfPresent(Bool.self, forKey: key) {
            return boolValue ? "true" : "false"
        }

        return nil
    }

    func decodeLossyStatus(forKey key: Key) throws -> String {
        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return stringValue ?? "false"
        }

        if let boolValue = try? decodeIfPresent(Bool.self, forKey: key) {
            return (boolValue ?? false) ? "true" : "false"
        }

        return "false"
    }

    func decodeLossyInt(forKey key: Key) throws -> Int {
        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue
        }

        if let stringValue = try? decode(String.self, forKey: key), let intValue = Int(stringValue) {
            return intValue
        }

        if let doubleValue = try? decode(Double.self, forKey: key) {
            return Int(doubleValue)
        }

        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unable to decode Int value.")
    }

    func decodeLossyIntIfPresent(forKey key: Key) throws -> Int? {
        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }

        if let stringValue = try? decodeIfPresent(String.self, forKey: key),
           let intValue = Int(stringValue) {
            return intValue
        }

        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return Int(doubleValue)
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

        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return Double(stringValue)
        }

        return nil
    }

    private func normalizedNullableString(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.isEmpty || trimmedValue.lowercased() == "<null>" {
            return nil
        }

        return trimmedValue
    }
}

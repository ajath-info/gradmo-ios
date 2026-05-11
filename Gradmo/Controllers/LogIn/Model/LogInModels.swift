//
//  LogInModels.swift
//  Gradmo
//

import Foundation

// MARK: - LoginUser
struct LoginUser: Codable {
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
    var imageURL: String?
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
        case imageURL     = "image_url"
        case roleID       = "role_id"
    }
}

// MARK: - Gradmo Login API Models
struct GradmoLoginResponse: Decodable {
    let status: String
    let msg: String?
    let data: GradmoLoginUserData?

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
        data = try container.decodeIfPresent(GradmoLoginUserData.self, forKey: .data)

        if let statusString = try? container.decodeIfPresent(String.self, forKey: .status) {
            status = statusString
        } else if let statusBool = try? container.decodeIfPresent(Bool.self, forKey: .status) {
            status = statusBool ? "true" : "false"
        } else {
            status = "false"
        }
    }
}

struct GradmoLoginUserData: Decodable {
    let userType: String?
    let userId: String?
    let studentId: Int?
    let teacherId: Int?
    let instituteId: Int?
    let name: String?
    let email: String?
    let mobile: String?
    let contactNo: String?
    let enrollmentId: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let pincode: String?
    let country: String?
    let state: String?
    let city: String?
    let schoolCollegeName: String?
    let grade: String?
    let image: String?
    let role: String?
    let deviceId: String?
    let deviceToken: String?
    let deviceType: String?
    let isProfileCompleted: Int?
    let accessToken: String?
    let tokenType: String?

    var resolvedUserID: String? {
        userId ?? studentId.map(String.init) ?? teacherId.map(String.init) ?? instituteId.map(String.init)
    }

    private enum CodingKeys: String, CodingKey {
        case userType
        case userId
        case studentId
        case teacherId
        case instituteId
        case name
        case email
        case mobile
        case contactNo
        case enrollmentId
        case address
        case latitude
        case longitude
        case pincode
        case country
        case state
        case city
        case schoolCollegeName
        case grade
        case image
        case role
        case deviceId = "device_id"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case isProfileCompleted = "is_profile_completed"
        case accessToken = "access_token"
        case tokenType = "token_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        userType = try container.decodeLossyStringIfPresent(forKey: .userType)
        userId = try container.decodeLossyStringIfPresent(forKey: .userId)
        studentId = try container.decodeLossyIntIfPresent(forKey: .studentId)
        teacherId = try container.decodeLossyIntIfPresent(forKey: .teacherId)
        instituteId = try container.decodeLossyIntIfPresent(forKey: .instituteId)
        name = try container.decodeLossyStringIfPresent(forKey: .name)
        email = try container.decodeLossyStringIfPresent(forKey: .email)
        mobile = try container.decodeLossyStringIfPresent(forKey: .mobile)
        contactNo = try container.decodeLossyStringIfPresent(forKey: .contactNo)
        enrollmentId = try container.decodeLossyStringIfPresent(forKey: .enrollmentId)
        address = try container.decodeLossyStringIfPresent(forKey: .address)
        latitude = try container.decodeLossyDoubleIfPresent(forKey: .latitude)
        longitude = try container.decodeLossyDoubleIfPresent(forKey: .longitude)
        pincode = try container.decodeLossyStringIfPresent(forKey: .pincode)
        country = try container.decodeLossyStringIfPresent(forKey: .country)
        state = try container.decodeLossyStringIfPresent(forKey: .state)
        city = try container.decodeLossyStringIfPresent(forKey: .city)
        schoolCollegeName = try container.decodeLossyStringIfPresent(forKey: .schoolCollegeName)
        grade = try container.decodeLossyStringIfPresent(forKey: .grade)
        image = try container.decodeLossyStringIfPresent(forKey: .image)
        role = try container.decodeLossyStringIfPresent(forKey: .role)
        deviceId = try container.decodeLossyStringIfPresent(forKey: .deviceId)
        deviceToken = try container.decodeLossyStringIfPresent(forKey: .deviceToken)
        deviceType = try container.decodeLossyStringIfPresent(forKey: .deviceType)
        isProfileCompleted = try container.decodeLossyIntIfPresent(forKey: .isProfileCompleted)
        accessToken = try container.decodeLossyStringIfPresent(forKey: .accessToken)
        tokenType = try container.decodeLossyStringIfPresent(forKey: .tokenType)
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

    func decodeLossyIntIfPresent(forKey key: Key) throws -> Int? {
        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }

        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
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

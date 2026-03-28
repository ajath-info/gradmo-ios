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

        if let statusString = try container.decodeIfPresent(String.self, forKey: .status) {
            status = statusString
        } else if let statusBool = try container.decodeIfPresent(Bool.self, forKey: .status) {
            status = statusBool ? "true" : "false"
        } else {
            status = "false"
        }
    }
}

struct GradmoLoginUserData: Decodable {
    let userType: String?
    let userId: String?
    let studentId: String?
    let teacherId: String?
    let instituteId: String?
    let name: String?
    let email: String?
    let mobile: String?
    let enrollmentId: String?
    let image: String?
    let role: String?
    let deviceId: String?
    let deviceToken: String?
    let deviceType: String?
    let isProfileCompleted: Int?
    let accessToken: String?
    let tokenType: String?

    var resolvedUserID: String? {
        userId ?? studentId ?? teacherId ?? instituteId
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
        case enrollmentId
        case image
        case role
        case deviceId = "device_id"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case isProfileCompleted = "is_profile_completed"
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

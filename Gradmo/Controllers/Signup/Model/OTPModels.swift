//
//  OTPModels.swift
//  Gradmo
//

import Foundation

struct SendOTPRequest {
    let name: String?
    let email: String?
    let mobile: String
    let userType: String

    func toParameters() -> [String: Any] {
        var parameters: [String: Any] = [
            APIKeys.mobile: mobile.toIndiaPhoneNumber(),
            APIKeys.userType: userType
        ]

        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters[APIKeys.name] = name
        }

        if let email, !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters["email"] = email
        }

        return parameters
    }
}

struct SendOTPResponse: Decodable {
    let status: Bool
    let msg: String?
    let data: SendOTPData?
    let otp: Int?

    private enum CodingKeys: String, CodingKey {
        case status
        case msg
        case data
        case otp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        data = try container.decodeIfPresent(SendOTPData.self, forKey: .data)
        otp = try container.decodeIfPresent(Int.self, forKey: .otp)

        if let boolStatus = try container.decodeIfPresent(Bool.self, forKey: .status) {
            status = boolStatus
        } else if let stringStatus = try container.decodeIfPresent(String.self, forKey: .status) {
            status = stringStatus.lowercased() == "true"
        } else {
            status = false
        }
    }
}

struct SendOTPData: Decodable {
    let mobile: String?
    let userType: String?

    enum CodingKeys: String, CodingKey {
        case mobile
        case userType = "user_type"
    }
}

struct VerifyOTPRequest {
    let mobile: String
    let otp: String
    let userType: String

    func toParameters() -> [String: Any] {
        [
            APIKeys.mobile: mobile,
            "otp": otp,
            APIKeys.userType: userType
        ]
    }
}

struct VerifyOTPResponse: Decodable {
    let status: Bool
    let msg: String?
    let data: VerifyOTPUserData?

    private enum CodingKeys: String, CodingKey {
        case status
        case msg
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        data = try container.decodeIfPresent(VerifyOTPUserData.self, forKey: .data)

        if let boolStatus = try container.decodeIfPresent(Bool.self, forKey: .status) {
            status = boolStatus
        } else if let stringStatus = try container.decodeIfPresent(String.self, forKey: .status) {
            status = stringStatus.lowercased() == "true"
        } else {
            status = false
        }
    }
}

struct VerifyOTPUserData: Decodable {
    let userType: String?
    let studentId: String?
    let teacherId: String?
    let instituteId: String?
    let name: String?
    let email: String?
    let mobile: String?
    let deviceId: String?
    let deviceToken: String?
    let deviceType: String?
    let backendUserType: String?
    let isProfileCompleted: Int?
    let accessToken: String?
    let tokenType: String?

    var resolvedUserID: String? {
        studentId ?? teacherId ?? instituteId
    }

    enum CodingKeys: String, CodingKey {
        case userType
        case studentId
        case teacherId
        case instituteId
        case name
        case email
        case mobile
        case deviceId = "device_id"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case backendUserType = "user_type"
        case isProfileCompleted = "is_profile_completed"
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

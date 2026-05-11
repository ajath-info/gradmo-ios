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
    let status: String
    let msg: String?
    let data: SendOTPData?
    let otp: Int?

    var isSuccess: Bool {
        status.lowercased() == "true"
    }

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
        otp = try container.decodeLossyIntIfPresent(forKey: .otp)

        if let boolStatus = try? container.decodeIfPresent(Bool.self, forKey: .status) {
            status = boolStatus ? "true" : "false"
        } else if let stringStatus = try? container.decodeIfPresent(String.self, forKey: .status) {
            status = stringStatus
        } else {
            status = "false"
        }
    }
}

struct SendOTPData: Decodable {
    let mobile: String?
    let userType: String?
    let userId: String?
    let name: String?
    let email: String?
    let image: String?
    let role: String?
    let deviceId: String?
    let deviceToken: String?
    let deviceType: String?

    enum CodingKeys: String, CodingKey {
        case mobile
        case userType
        case userId
        case name
        case email
        case image
        case role
        case deviceId = "device_id"
        case deviceToken = "device_token"
        case deviceType = "device_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        mobile = try container.decodeLossyStringIfPresent(forKey: .mobile)
        userType = try container.decodeLossyStringIfPresent(forKey: .userType)
        userId = try container.decodeLossyStringIfPresent(forKey: .userId)
        name = try container.decodeLossyStringIfPresent(forKey: .name)
        email = try container.decodeLossyStringIfPresent(forKey: .email)
        image = try container.decodeLossyStringIfPresent(forKey: .image)
        role = try container.decodeLossyStringIfPresent(forKey: .role)
        deviceId = try container.decodeLossyStringIfPresent(forKey: .deviceId)
        deviceToken = try container.decodeLossyStringIfPresent(forKey: .deviceToken)
        deviceType = try container.decodeLossyStringIfPresent(forKey: .deviceType)
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
    let status: String
    let msg: String?
    let data: VerifyOTPUserData?

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
        data = try container.decodeIfPresent(VerifyOTPUserData.self, forKey: .data)

        if let boolStatus = try? container.decodeIfPresent(Bool.self, forKey: .status) {
            status = boolStatus ? "true" : "false"
        } else if let stringStatus = try? container.decodeIfPresent(String.self, forKey: .status) {
            status = stringStatus
        } else {
            status = "false"
        }
    }
}

struct VerifyOTPUserData: Decodable {
    let userType: String?
    let userId: String?
    let studentId: Int?
    let teacherId: Int?
    let instituteId: Int?
    let name: String?
    let email: String?
    let mobile: String?
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

    enum CodingKeys: String, CodingKey {
        case userType
        case userId
        case studentId
        case teacherId
        case instituteId
        case name
        case email
        case mobile
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

        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        }

        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return Int(doubleValue)
        }

        return nil
    }

    private func normalizedNullableString(_ value: String) -> String? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.isEmpty || trimmedValue.lowercased() == "<null>" {
            return nil
        }
        return trimmedValue
    }
}

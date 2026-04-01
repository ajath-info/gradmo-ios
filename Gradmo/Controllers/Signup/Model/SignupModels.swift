//
//  SignupModels.swift
//  Gradmo
//

import Foundation

struct SignupUpsertRequest {
    var userType: String
    var name: String
    var email: String
    var mobile: String
    var password: String?
    var deviceId: String?
    var deviceToken: String?
    var deviceType: String?
    var country: String?
    var state: String?
    var city: String?
    var pincode: String?
    var studentId: String?
    var teacherId: String?
    var instituteId: String?
    var enrollmentId: String?
    var batchId: String?
    var adminId: String?
    var image: String?

    func toParameters() -> [String: Any] {
        var params: [String: Any] = [
            APIKeys.userType: userType,
            APIKeys.name: name,
            "email": email,
            APIKeys.mobile: mobile
        ]

        if let password, !password.isEmpty { params[APIKeys.password] = password }
        if let deviceId { params[APIKeys.device_id] = deviceId }
        if let deviceToken { params[APIKeys.device_token] = deviceToken }
        if let deviceType { params[APIKeys.device_type] = deviceType }
        if let country, !country.isEmpty { params[APIKeys.country] = country }
        if let state, !state.isEmpty { params[APIKeys.state] = state }
        if let city, !city.isEmpty { params[APIKeys.city] = city }
        if let pincode, !pincode.isEmpty { params[APIKeys.pincode] = pincode }
        if let studentId, !studentId.isEmpty { params[APIKeys.studentId] = studentId }
        if let teacherId, !teacherId.isEmpty { params[APIKeys.teacherId] = teacherId }
        if let instituteId, !instituteId.isEmpty { params[APIKeys.instituteId] = instituteId }
        if let enrollmentId, !enrollmentId.isEmpty { params[APIKeys.enrollmentId] = enrollmentId }
        if let batchId, !batchId.isEmpty { params[APIKeys.batchId] = batchId }
        if let adminId, !adminId.isEmpty { params[APIKeys.adminId] = adminId }
        if let image, !image.isEmpty { params[APIKeys.image] = image }

        return params
    }
}

struct SignupUpsertResponse: Decodable {
    let status: String
    let msg: String?
    let data: SignupUserData?
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
        data = try container.decodeIfPresent(SignupUserData.self, forKey: .data)
        otp = try container.decodeLossyIntIfPresent(forKey: .otp)

        if let statusString = try container.decodeIfPresent(String.self, forKey: .status) {
            status = statusString
        } else if let statusBool = try container.decodeIfPresent(Bool.self, forKey: .status) {
            status = statusBool ? "true" : "false"
        } else {
            status = "false"
        }
    }
}

struct SignupUserData: Decodable {
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
    let batchId: String?
    let adminId: String?
    let country: String?
    let state: String?
    let city: String?
    let pincode: String?

    var resolvedUserID: String? {
        userId ?? studentId ?? teacherId ?? instituteId
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
        case enrollmentId
        case image
        case role
        case deviceId = "device_id"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case batchId
        case adminId
        case country
        case state
        case city
        case pincode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        userType = try container.decodeLossyStringIfPresent(forKey: .userType)
        userId = try container.decodeLossyStringIfPresent(forKey: .userId)
        studentId = try container.decodeLossyStringIfPresent(forKey: .studentId)
        teacherId = try container.decodeLossyStringIfPresent(forKey: .teacherId)
        instituteId = try container.decodeLossyStringIfPresent(forKey: .instituteId)
        name = try container.decodeLossyStringIfPresent(forKey: .name)
        email = try container.decodeLossyStringIfPresent(forKey: .email)
        mobile = try container.decodeLossyStringIfPresent(forKey: .mobile)
        enrollmentId = try container.decodeLossyStringIfPresent(forKey: .enrollmentId)
        image = try container.decodeLossyStringIfPresent(forKey: .image)
        role = try container.decodeLossyStringIfPresent(forKey: .role)
        deviceId = try container.decodeLossyStringIfPresent(forKey: .deviceId)
        deviceToken = try container.decodeLossyStringIfPresent(forKey: .deviceToken)
        deviceType = try container.decodeLossyStringIfPresent(forKey: .deviceType)
        batchId = try container.decodeLossyStringIfPresent(forKey: .batchId)
        adminId = try container.decodeLossyStringIfPresent(forKey: .adminId)
        country = try container.decodeLossyStringIfPresent(forKey: .country)
        state = try container.decodeLossyStringIfPresent(forKey: .state)
        city = try container.decodeLossyStringIfPresent(forKey: .city)
        pincode = try container.decodeLossyStringIfPresent(forKey: .pincode)
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

    private func normalizedNullableString(_ value: String) -> String? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.isEmpty || trimmedValue.lowercased() == "<null>" {
            return nil
        }
        return trimmedValue
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
}

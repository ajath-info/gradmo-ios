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
        otp = try container.decodeIfPresent(Int.self, forKey: .otp)

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
    let studentId: String?
    let teacherId: String?
    let instituteId: String?
    let name: String?
    let email: String?
    let mobile: String?
    let enrollmentId: String?
    let image: String?
    let deviceId: String?
    let deviceToken: String?
    let deviceType: String?
    let batchId: String?
    let adminId: String?
    let country: String?
    let state: String?
    let city: String?
    let pincode: String?

    enum CodingKeys: String, CodingKey {
        case userType
        case studentId
        case teacherId
        case instituteId
        case name
        case email
        case mobile
        case enrollmentId
        case image
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
}

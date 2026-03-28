//
//  CompleteProfileModels.swift
//  Gradmo
//

import Foundation

struct CompleteProfileUpdateProfileRequest {
    let name: String
    let email: String
    let mobile: String
    let userType: String
    let address: String
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

        if let statusString = try container.decodeIfPresent(String.self, forKey: .status) {
            status = statusString
        } else if let statusBool = try container.decodeIfPresent(Bool.self, forKey: .status) {
            status = statusBool ? "true" : "false"
        } else {
            status = "false"
        }
    }
}

struct CompleteProfileUpdatedUserData: Decodable {
    let id: String?
    let adminId: String?
    let name: String?
    let enrollmentId: String?
    let image: String?
    let email: String?
    let contactNo: String?
    let mobile: String?
    let address: String?
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
        case adminId = "admin_id"
        case name
        case enrollmentId = "enrollment_id"
        case image
        case email
        case contactNo = "contact_no"
        case mobile
        case address
        case pincode
        case country
        case state
        case city
        case schoolCollegeName = "school_college_name"
        case grade
        case deviceId = "device_id"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case userType = "user_type"
        case isProfileCompleted = "is_profile_completed"
    }
}

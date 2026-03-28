//
//  Models.swift
//  Gradmo
//

import Foundation

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

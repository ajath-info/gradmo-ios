//
//  APIKeys.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 04/09/25.
//

import Foundation

//MARK: - API Endpoints
struct API {
    //USER
    static let createUserAPI = "create-user"
    static let loginUserAPI = "api/user/login"
    static let signupUserAPI = "api/user/signup"
    static let sendOtpAPI = "api/user/send-otp"
    static let verifyOtpAPI = "api/user/verify-otp"
    static let updatePasswordAPI = "api/user/update-password"
    static let updateProfileAPI = "api/user/update-profile"
    static let logoutAPI = "api/user/logout"
    static let deleteAccountAPI = "api/user/delete-account"
    static let sendVerificationOtpAPI = "send-verification-otp"
    static let updateUserAPI = "update-user"
    static let getMyProfileAPI = "get-my-profile"
    static let sendForgetPasswordOtpAPI = "send-forget-password-otp"
    static let verifyForgetPasswordOtpAPI = "verify-forget-password-otp"
    static let resetPasswordAPI = "reset-password"
    static let verifyUserEmailAPI = "verify-user-email"
    static let getUserDetailByIdAPI = "auth/get-user-details-by-id"
    static let submitHelpQueryAPI = "create-help-and-support"
    //MASTER
    static let getUserRoleAPI = "get-user-role"
    static let saveUserDeviceDetailsAPI = "save-user-device-details"
    static let getCounsellorServicesAPI = "master/counselor-services"
    static let getCommunicationPreferencesAPI = "master/communication-preferences"
    //CONNECTION
    static let sendConnectionAPI = "connection/send"
    static let acceptConnectionAPI = "connection/accept"
    static let denyConnectionAPI = "connection/deny"
    static let cancelConnectionAPI = "connection/cancel"
    static let requestConnectionListAPI = "connection/requests"
    static let connectionListAPI = "connection/list"
    static let disconnectUserAPI = "connection/remove"
    static let studentConnectionListAPI = "connection/student-connections"
    //CHAT
    static let creatChatAPI = "chat/create-chat"
    static let getChatByIdAPI = "chat/get-chat-by-id"
    static let getAllChatAPI = "chat/get-all-chats"
    static let clearChat = "chat/clear-chats"
    //SCHOLARSHIP
    static let getAllScholarshipAPI = "scholarships/"
    static let myScholarshipAPI = "scholarships/my?"
    static let getReportReasonAPI = "master/master-flags"
    static let getFilterSubjectAreasAPI = "master/academic-interests"
    static let getFilterStatesAPI = "master/master-states"
    static let getFilterEasyApplyOptionsAPI = "master/master-easy-apply"
    static let getFilterUnderrepresentedIdentitiesOptionAPI = "master/master-underrepresented-identities"
    static let filterScholarshipAPI = "scholarships/search/"
    static let postScholarshipAPI = "scholarships/"
    static let updateScholarshipAPI = "scholarships/"
    static let bookmarkScholarshipAPI = "scholarships/bookmark"
    static let removeBookmarkScholarshipAPI = "scholarships/remove-bookmark"
    static let getMyBookmarkedScholarshipAPI = "scholarships/bookmarked"
    static let reportScholarshipAPI = "scholarships/report"
    static let matchedScholarshipAPI = "scholarships/matched?"
    //SCHOLARSHIP SURVEY
    static let getSurveyDetailsAPI = "student/profile"
    static let getCounsellorSurveyDetailsAPI = "counselor/profile"
    //ARTICLE
    static let getAllArticleAPI = "articles/published"
    static let getMyArticleAPI = "articles/mine/"
    static let createArticleAPI = "articles/create"
    static let updateArticleAPI = "articles/"
    //APPLICATION(CAFSA/FAFSA)
    static let applicationTypeAPI = "financial-aid/create-financial-aid"
    static let updateApplicationAPI = "financial-aid/update-financial-aid"
    static let getMyApplicationAPI = "financial-aid/get-financial-aid"
    //TASK
    static let createTaskAPI = "tasks/create"
    static let getTaskToAssignStudentListAPI = "connection/master-list"
    static let getMyCreatedTaskForOthersListAPI = "tasks/my-created-for-others"
    static let getMyCreatedTaskForMeListAPI = "tasks/my-created"
    static let getOthersCreatedTaskForMeListAPI = "tasks/others-created-for-me"
    static let markTaskCompleteAPI = "tasks/"
    static let getTrackStudentTasksAPI = "student/all-students"
    //COLLEGE COMPARISION
    static let compareCollegeAPI = "college/create"
    static let getCollegeListAPI = "college/master-college"
    //COUNTDOWN
    static let createGraduationCountdown = "graduation-countdown/create"
    static let getGraduationCountdown = "graduation-countdown/get-countdown"
    static let updateGraduationCountdown = "graduation-countdown/update"
    static let shareCountdownAPI = "graduation-countdown/share-countdown"
    static let deleteCountdownAPI = "graduation-countdown/delete"
    //COLLEGE EXPENSES
    static let collegeExpenseAPI = "college/calculate-expense"
    static let lifestyleActivitiesAPI = "master/lifestyle-activities"
}

//MARK: - API Parameter Keys
struct APIKeys {
    //Keys For Create
    static let username = "username"
    static let userType = "user_type"
    static let name = "name"
    static let mobile = "mobile"
    static let batch_id = "batch_id"
    static let device_id = "device_id"
    static let device_token = "device_token"
    static let device_type = "device_type"
    static let country = "country"
    static let pincode = "pincode"
    static let studentId = "studentId"
    static let teacherId = "teacherId"
    static let instituteId = "instituteId"
    static let enrollmentId = "enrollmentId"
    static let batchId = "batchId"
    static let adminId = "adminId"
    static let image = "image"
    static let role = "role"
    static let firstName = "first_name"
    static let lastName = "last_name"
    static let email = "email_id"
    static let password = "password"
    static let city = "city"
    static let address = "address"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let countryCode = "country_code"
    static let phoneNumber = "phone_number"
    static let state = "state"
    static let confirmPassword = "confirm_password"

    static let OTP = "OTP"
    static let sent_by = "sent_by"
    static let sent_to = "sent_to"
    static let chat_id = "chat_id"
    static let page_no = "page_no"
    static let user_id = "user_id"
}

//MARK: - API Response Keys
struct SessionUser {
    //Auth
    static let auth = "token"
    static let deviceToken = "deviceToken"
    //User Info
    static let userId = "user_id"
    static let emailid = "email_id"
    static let isBlocked = "is_blocked"
    static let isVerified = "is_verified"
    static let createdDatetime = "created_datetime"
    static let updatedDatetime = "updated_datetime"
    //Profile Info
    static let firstname = "first_name"
    static let lastname = "last_name"
    static let state = "state"
    static let city = "city"
    static let countryCode = "country_code"
    static let phone = "phone_number"
    static let address = "address"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let profileImage = "image_url"
    //Roles
    static let roleId = "role_id"   // agar API role_id bhej rahi ho
    static let roles = "user_roles" // pura array of roles store karne ke liye
}

//MARK: - Login & SignUp UserDefault Keys
struct LoginKeys {
    static let selectedUserRole = "SelectedUserRole"
    static let isLoggedIn = "isLoggedIn"
    static let didSeeOnboarding = "didSeeOnboarding"
    static let didFinishSignupFlow = "didFinishSignupFlow"
}

//
//  UserCache.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 04/09/25.
//

import Foundation

class UserCache1 {
    static let share = UserCache1()
    static func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: SessionUser.auth)
    }
    
    static func authtoken() -> String {
        return UserDefaults.standard.string(forKey: SessionUser.auth) ?? ""
    }
}

class UserCache:NSObject {
    
    static let shared = UserCache()
//    static func saveToken(_ token: String) {
//        UserDefaults.standard.set(token, forKey: SessionUser.auth)
//    }
//
//    class func authtoken()->String {
//        return UserDefaults.standard.object(forKey: SessionUser.auth) as? String ?? ""
//    }
    class func firstName()->String {
        return UserDefaults.standard.object(forKey: SessionUser.firstname) as? String ?? ""
    }
    class func lastName()->String {
        return UserDefaults.standard.object(forKey: SessionUser.lastname) as? String ?? ""
    }
    class func fullName() -> String {
        let first = firstName().trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName().trimmingCharacters(in: .whitespacesAndNewlines)
        return [first, last]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    class func email_id()->String {
        return UserDefaults.standard.object(forKey: SessionUser.emailid) as? String ?? ""
    }
    class func userID()->String {
        return UserDefaults.standard.object(forKey: SessionUser.userId) as? String ?? ""
    }
    class func state()->String {
        return UserDefaults.standard.object(forKey: SessionUser.state) as? String ?? ""
    }
    class func city()->String {
        return UserDefaults.standard.object(forKey: SessionUser.city) as? String ?? ""
    }
    class func countryCode()->String {
        return UserDefaults.standard.object(forKey: SessionUser.countryCode) as? String ?? ""
    }
    class func phone()->String {
        return UserDefaults.standard.object(forKey: SessionUser.phone) as? String ?? ""
    }
    class func profileImageURL() -> String {
        return UserDefaults.standard.object(forKey: SessionUser.profileImage) as? String ?? ""
    }
    class func address() -> String {
        return UserDefaults.standard.object(forKey: SessionUser.address) as? String ?? ""
    }
    class func latitude() -> String {
        return UserDefaults.standard.string(forKey: SessionUser.latitude) ?? UserCache.defaultCoordinateValue
    }
    class func longitude() -> String {
        return UserDefaults.standard.string(forKey: SessionUser.longitude) ?? UserCache.defaultCoordinateValue
    }
    class func country() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.country) ?? ""
    }
    class func pincode() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.pincode) ?? ""
    }
    class func schoolCollegeName() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.schoolCollegeName) ?? ""
    }
    class func grade() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.grade) ?? ""
    }
    class func studentID() -> String {
        if let stringValue = UserDefaults.standard.string(forKey: UserCacheKeys.studentId) {
            return stringValue
        }

        if let intValue = UserDefaults.standard.object(forKey: UserCacheKeys.studentId) as? Int {
            return String(intValue)
        }

        return ""
    }
    class func teacherID() -> String {
        if let stringValue = UserDefaults.standard.string(forKey: UserCacheKeys.teacherId) {
            return stringValue
        }

        if let intValue = UserDefaults.standard.object(forKey: UserCacheKeys.teacherId) as? Int {
            return String(intValue)
        }

        return ""
    }
    class func instituteID() -> String {
        if let stringValue = UserDefaults.standard.string(forKey: UserCacheKeys.instituteId) {
            return stringValue
        }

        if let intValue = UserDefaults.standard.object(forKey: UserCacheKeys.instituteId) as? Int {
            return String(intValue)
        }

        return ""
    }
    class func currentScopedUserID(for role: UserRole) -> String {
        switch role {
        case .student:
            return studentID().isEmpty ? userID() : studentID()
        case .teacher:
            return teacherID().isEmpty ? userID() : teacherID()
        case .institute:
            return instituteID().isEmpty ? userID() : instituteID()
        }
    }
    class func roleID()->Int {
        return UserDefaults.standard.object(forKey: SessionUser.roleId) as? Int ?? 0
    }

    class func deviceToken()->String {
        return UserDefaults.standard.object(forKey: SessionUser.deviceToken) as? String ?? ""
    }
    class func saveCoordinates(latitude: Double?, longitude: Double?) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(latitude.formattedCoordinate, forKey: SessionUser.latitude)
        userDefaults.setValue(longitude.formattedCoordinate, forKey: SessionUser.longitude)
        userDefaults.synchronize()
    }

    class func printSavedDefaults() {
        let defaults = UserDefaults.standard.dictionaryRepresentation()
        let sortedKeys = defaults.keys.sorted()

        debugPrint("===== Saved UserDefaults =====")
        sortedKeys.forEach { key in
            debugPrint("\(key): \(String(describing: defaults[key]!))")
        }
        debugPrint("===== End UserDefaults =====")
    }

    class func logout() {
        let didSeeOnboarding = UserDefaults.standard.bool(forKey: LoginKeys.didSeeOnboarding)
        UserDefaults.standard.set(false, forKey: LoginKeys.isLoggedIn)
        UserDefaults.clearAll()
        UserDefaults.standard.set(didSeeOnboarding, forKey: LoginKeys.didSeeOnboarding)
    }
    class func token() -> String {
        return UserDefaults.standard.string(forKey: SessionUser.auth) ?? ""
    }

    
    class func selectedUserRole() -> UserRole? {
        guard let roleString = UserDefaults.standard.string(forKey: LoginKeys.selectedUserRole) else {
            return nil
        }

        return UserRole(storageValue: roleString)
    }

    class func saveSelectedUserRole(_ role: UserRole) {
        UserDefaults.standard.setValue(role.rawValue, forKey: LoginKeys.selectedUserRole)
    }

    class func clearSelectedUserRole() {
        UserDefaults.standard.removeObject(forKey: LoginKeys.selectedUserRole)
    }
    
    class func getUserRole() -> UserRole {
        // First priority: backend role_id
        let roleID = UserDefaults.standard.string(forKey: SessionUser.roleId) ?? ""
        if let userRole = UserRole(storageValue: roleID) {
            return userRole
        }

        // Second priority: manually selected role
        if let selected = UserDefaults.standard.string(forKey: LoginKeys.selectedUserRole),
           let manualRole = UserRole(storageValue: selected) {
            return manualRole
        }

        // Fallback
        return .student
    }

    
}

extension UserCache {
    func saveUserDataWhenCreateNewUser(model: CreateUserModel?, token: String?) {
        guard let model = model else { return }
        let userDefault = UserDefaults.standard
        
        if let token = token {
            userDefault.setValue(token, forKey: SessionUser.auth)
        }
        userDefault.setValue(model.userID, forKey: SessionUser.userId)
        userDefault.setValue(model.emailID, forKey: SessionUser.emailid)
        userDefault.setValue(model.isBlocked, forKey: SessionUser.isBlocked)
        userDefault.setValue(model.isVerified, forKey: SessionUser.isVerified)
        userDefault.setValue(model.firstName, forKey: SessionUser.firstname)
        userDefault.setValue(model.lastName, forKey: SessionUser.lastname)
        userDefault.setValue(model.state, forKey: SessionUser.state)
        userDefault.setValue(model.city, forKey: SessionUser.city)
        userDefault.setValue(model.countryCode, forKey: SessionUser.countryCode)
        userDefault.setValue(model.phoneNumber, forKey: SessionUser.phone)
        userDefault.setValue(model.address, forKey: SessionUser.address)
        userDefault.setValue(model.latitude.formattedCoordinate, forKey: SessionUser.latitude)
        userDefault.setValue(model.longitude.formattedCoordinate, forKey: SessionUser.longitude)

//        let roles = model.roles ?? []
//        userDefault.setValue(roles, forKey: SessionUser.roles)
        userDefault.setValue(model.roleID, forKey: SessionUser.roleId)
        userDefault.synchronize()
        debugPrint("User data saved in UserDefaults")
    }
    
    func saveUserDataWhenLogin(model: LoginUser?, token: String?) {
        guard let model = model else { return }
        let userDefault = UserDefaults.standard

        // Save Token
        if let token = token {
            userDefault.setValue(token, forKey: SessionUser.auth)
        }

        // Save Main User Info
        userDefault.setValue(model.userID, forKey: SessionUser.userId)
        userDefault.setValue(model.emailID, forKey: SessionUser.emailid)
        userDefault.setValue(model.isBlocked, forKey: SessionUser.isBlocked)
        userDefault.setValue(model.isVerified, forKey: SessionUser.isVerified)
        // Save User Profile
        userDefault.setValue(model.firstName, forKey: SessionUser.firstname)
        userDefault.setValue(model.lastName, forKey: SessionUser.lastname)
        userDefault.setValue(model.state, forKey: SessionUser.state)
        userDefault.setValue(model.city, forKey: SessionUser.city)
        userDefault.setValue(model.countryCode, forKey: SessionUser.countryCode)
        userDefault.setValue(model.phoneNumber, forKey: SessionUser.phone)
        userDefault.setValue(model.address, forKey: SessionUser.address)
        userDefault.setValue(model.latitude.formattedCoordinate, forKey: SessionUser.latitude)
        userDefault.setValue(model.longitude.formattedCoordinate, forKey: SessionUser.longitude)
        userDefault.setValue(model.imageURL, forKey: SessionUser.profileImage)
        userDefault.setValue(model.roleID, forKey: SessionUser.roleId)

        userDefault.synchronize()
        debugPrint("Full user data saved in UserDefaults")
    }

    func saveUpdatedProfileData(model: CompleteProfileUpdatedUserData?, token: String?) {
        guard let model = model else { return }

        let nameParts = (model.name ?? "").split(separator: " ").map(String.init)
        let firstName = nameParts.first
        let lastName = nameParts.dropFirst().joined(separator: " ")

        let loginUser = LoginUser(
            userID: model.id,
            emailID: model.email,
            isBlocked: nil,
            isVerified: nil,
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            state: model.state,
            city: model.city,
            countryCode: nil,
            phoneNumber: model.mobile,
            address: model.address,
            latitude: model.latitude,
            longitude: model.longitude,
            imageURL: model.image,
            roleID: model.userType
        )

        saveUserDataWhenLogin(model: loginUser, token: token)

        let userDefault = UserDefaults.standard
        userDefault.setValue(model.country, forKey: UserCacheKeys.country)
        userDefault.setValue(model.pincode, forKey: UserCacheKeys.pincode)
        userDefault.setValue(model.schoolCollegeName, forKey: UserCacheKeys.schoolCollegeName)
        userDefault.setValue(model.grade, forKey: UserCacheKeys.grade)
        userDefault.synchronize()
    }

    func saveLoginProfileFields(country: String?, pincode: String?, schoolCollegeName: String?, grade: String?) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(country, forKey: UserCacheKeys.country)
        userDefault.setValue(pincode, forKey: UserCacheKeys.pincode)
        userDefault.setValue(schoolCollegeName, forKey: UserCacheKeys.schoolCollegeName)
        userDefault.setValue(grade, forKey: UserCacheKeys.grade)
        userDefault.synchronize()
    }

    func saveScopedUserIDs(studentId: Int?, teacherId: Int?, instituteId: Int?) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(studentId, forKey: UserCacheKeys.studentId)
        userDefault.setValue(teacherId, forKey: UserCacheKeys.teacherId)
        userDefault.setValue(instituteId, forKey: UserCacheKeys.instituteId)
        userDefault.synchronize()
    }

    func saveEditedProfileData(name: String,
                               email: String,
                               phone: String,
                               address: String,
                               country: String,
                               state: String,
                               city: String,
                               pincode: String,
                               schoolCollegeName: String,
                               grade: String,
                               imageURL: String,
                               userID: String,
                               roleID: String,
                               latitude: String,
                               longitude: String,
                               token: String?) {
        let nameParts = name.split(separator: " ").map(String.init)
        let firstName = nameParts.first
        let lastName = nameParts.dropFirst().joined(separator: " ")

        let loginUser = LoginUser(
            userID: userID.isEmpty ? nil : userID,
            emailID: email,
            isBlocked: nil,
            isVerified: nil,
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            state: state,
            city: city,
            countryCode: nil,
            phoneNumber: phone,
            address: address,
            latitude: Double(latitude),
            longitude: Double(longitude),
            imageURL: imageURL,
            roleID: roleID
        )

        saveUserDataWhenLogin(model: loginUser, token: token)

        let userDefault = UserDefaults.standard
        userDefault.setValue(country, forKey: UserCacheKeys.country)
        userDefault.setValue(pincode, forKey: UserCacheKeys.pincode)
        userDefault.setValue(schoolCollegeName, forKey: UserCacheKeys.schoolCollegeName)
        userDefault.setValue(grade, forKey: UserCacheKeys.grade)
        userDefault.synchronize()
    }
}

private extension Optional where Wrapped == Double {
    var formattedCoordinate: String {
        let value = self ?? 0
        return String(format: "%.4f", value)
    }
}

private extension UserCache {
    static let defaultCoordinateValue = "0.0000"
}

private enum UserCacheKeys {
    static let accessKey = "com.motivaid.usercache.accessKey"
    static let secretKey = "com.motivaid.usercache.secretKey"
    static let bucket    = "com.motivaid.usercache.bucket"
    static let region    = "com.motivaid.usercache.region"
    static let fafsaLink    = "com.motivaid.usercache.fafsaLink"
    static let casfaLink    = "com.motivaid.usercache.casfaLink"
    static let country = "com.motivaid.usercache.country"
    static let pincode = "com.motivaid.usercache.pincode"
    static let schoolCollegeName = "com.motivaid.usercache.schoolCollegeName"
    static let grade = "com.motivaid.usercache.grade"
    static let studentId = "com.motivaid.usercache.studentId"
    static let teacherId = "com.motivaid.usercache.teacherId"
    static let instituteId = "com.motivaid.usercache.instituteId"
    static let paymentGatewayId = "com.gradmo.defaults.paymentGateway.id"
    static let paymentGateway = "com.gradmo.defaults.paymentGateway.gateway"
    static let razorpayKeyID = "com.gradmo.defaults.razorpay.keyID"
    static let razorpaySecretKey = "com.gradmo.defaults.razorpay.secretKey"
    static let razorpayWebhookSecret = "com.gradmo.defaults.razorpay.webhookSecret"
    static let razorpayMode = "com.gradmo.defaults.razorpay.mode"
    static let razorpayStatus = "com.gradmo.defaults.razorpay.status"
    static let zoomId = "com.gradmo.defaults.zoom.id"
    static let zoomAPIKey = "com.gradmo.defaults.zoom.apiKey"
    static let zoomSDKKey = "com.gradmo.defaults.zoom.sdkKey"
    static let zoomSecretKey = "com.gradmo.defaults.zoom.secretKey"
    static let zoomSDKSecret = "com.gradmo.defaults.zoom.sdkSecret"
    static let zoomJWTToken = "com.gradmo.defaults.zoom.jwtToken"
    static let zoomDomain = "com.gradmo.defaults.zoom.domain"
    static let zoomMode = "com.gradmo.defaults.zoom.mode"
    static let zoomStatus = "com.gradmo.defaults.zoom.status"
}

extension UserCache {
    // Saveers
    static func saveAccessKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: UserCacheKeys.accessKey)
    }
    static func saveSecretKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: UserCacheKeys.secretKey)
    }
    static func saveBucket(_ name: String) {
        UserDefaults.standard.set(name, forKey: UserCacheKeys.bucket)
    }
    static func saveRegion(_ region: String) {
        UserDefaults.standard.set(region, forKey: UserCacheKeys.region)
    }
    static func saveFafsaLink(_ region: String) {
        UserDefaults.standard.set(region, forKey: UserCacheKeys.fafsaLink)
    }
    static func saveCasfaLink(_ region: String) {
        UserDefaults.standard.set(region, forKey: UserCacheKeys.casfaLink)
    }
    

    // Getters (optional returns, empty-string fallback for convenience)
    static func accessKey() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.accessKey) ?? ""
    }
    static func secretKey() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.secretKey) ?? ""
    }
    static func bucket() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.bucket) ?? ""
    }
    static func region() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.region) ?? ""
    }
    static func fafsaLink() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.fafsaLink) ?? ""
    }
    static func casfaLink() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.casfaLink) ?? ""
    }

    // Optional: clear cache
    static func clearAWSCache() {
        UserDefaults.standard.removeObject(forKey: UserCacheKeys.accessKey)
        UserDefaults.standard.removeObject(forKey: UserCacheKeys.secretKey)
        UserDefaults.standard.removeObject(forKey: UserCacheKeys.bucket)
        UserDefaults.standard.removeObject(forKey: UserCacheKeys.region)
        UserDefaults.standard.removeObject(forKey: UserCacheKeys.fafsaLink)
        UserDefaults.standard.removeObject(forKey: UserCacheKeys.casfaLink)
    }

    static func savePaymentGatewayCredentials(
        id: String?,
        gateway: String?,
        keyID: String?,
        secretKey: String?,
        webhookSecret: String?,
        mode: String?,
        status: String?
    ) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(id, forKey: UserCacheKeys.paymentGatewayId)
        userDefaults.setValue(gateway, forKey: UserCacheKeys.paymentGateway)
        userDefaults.setValue(keyID, forKey: UserCacheKeys.razorpayKeyID)
        userDefaults.setValue(secretKey, forKey: UserCacheKeys.razorpaySecretKey)
        userDefaults.setValue(webhookSecret, forKey: UserCacheKeys.razorpayWebhookSecret)
        userDefaults.setValue(mode, forKey: UserCacheKeys.razorpayMode)
        userDefaults.setValue(status, forKey: UserCacheKeys.razorpayStatus)
        userDefaults.synchronize()
    }

    static func razorpayKeyID() -> String {
        UserDefaults.standard.string(forKey: UserCacheKeys.razorpayKeyID) ?? ""
    }

    static func razorpaySecretKey() -> String {
        UserDefaults.standard.string(forKey: UserCacheKeys.razorpaySecretKey) ?? ""
    }

    static func razorpayWebhookSecret() -> String {
        UserDefaults.standard.string(forKey: UserCacheKeys.razorpayWebhookSecret) ?? ""
    }

    static func saveZoomCredentials(
        id: String?,
        apiKey: String?,
        sdkKey: String?,
        secretKey: String?,
        sdkSecret: String?,
        jwtToken: String?,
        domain: String?,
        mode: String?,
        status: String?
    ) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(id, forKey: UserCacheKeys.zoomId)
        userDefaults.setValue(apiKey, forKey: UserCacheKeys.zoomAPIKey)
        userDefaults.setValue(sdkKey, forKey: UserCacheKeys.zoomSDKKey)
        userDefaults.setValue(secretKey, forKey: UserCacheKeys.zoomSecretKey)
        userDefaults.setValue(sdkSecret, forKey: UserCacheKeys.zoomSDKSecret)
        userDefaults.setValue(jwtToken, forKey: UserCacheKeys.zoomJWTToken)
        userDefaults.setValue(domain, forKey: UserCacheKeys.zoomDomain)
        userDefaults.setValue(mode, forKey: UserCacheKeys.zoomMode)
        userDefaults.setValue(status, forKey: UserCacheKeys.zoomStatus)
        userDefaults.synchronize()
    }

    static func zoomSDKDomain() -> String {
        UserDefaults.standard.string(forKey: UserCacheKeys.zoomDomain) ?? ""
    }

    static func zoomSDKJWTToken() -> String {
        UserDefaults.standard.string(forKey: UserCacheKeys.zoomJWTToken) ?? ""
    }

    static func zoomSecretKey() -> String {
        UserDefaults.standard.string(forKey: UserCacheKeys.zoomSecretKey) ?? ""
    }
}

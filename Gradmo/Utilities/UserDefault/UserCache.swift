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
        return UserDefaults.standard.string(forKey: UserCacheKeys.studentId) ?? ""
    }
    class func teacherID() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.teacherId) ?? ""
    }
    class func instituteID() -> String {
        return UserDefaults.standard.string(forKey: UserCacheKeys.instituteId) ?? ""
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
        userDefault.setValue(model.latitude, forKey: SessionUser.latitude)
        userDefault.setValue(model.longitude, forKey: SessionUser.longitude)

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
        userDefault.setValue(model.latitude, forKey: SessionUser.latitude)
        userDefault.setValue(model.longitude, forKey: SessionUser.longitude)
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
            latitude: nil,
            longitude: nil,
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

    func saveScopedUserIDs(studentId: String?, teacherId: String?, instituteId: String?) {
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
            latitude: nil,
            longitude: nil,
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
}

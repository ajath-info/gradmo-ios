//
//  UserSessionManager.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 04/09/25.
//

import Foundation


class UserSessionManager {
    
    static let shared = UserSessionManager()
    private let tokenKey = "token"
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func isLoggedIn() -> Bool {
        return getToken() != nil
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}

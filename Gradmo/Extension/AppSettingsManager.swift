//
//  AppSettingsManager.swift
//  Motivaid
//
//  Created by Rishabh   on 26/11/25.
//
// AppSettingsManager.swift

import Foundation

// MARK: - AppSettings
struct AppSettings: Codable {
    let secretKey: String?
    let accessKey: String?
    let bucketName: String?
    let region: String?
    let fafsaLink: String?
    let casfaLink: String?

    enum CodingKeys: String, CodingKey {
        case secretKey = "secret_key"
        case accessKey = "access_key"
        case bucketName = "bucket-name"
        case region
        case fafsaLink = "fafsa_link"
        case casfaLink = "casfa_link"
    }
}

// MARK: - Wrapper for API response
struct AppSettingsResponse: Codable {
    let data: AppSettings
}

// MARK: - Manager
class AppSettingsManager {
    static let shared = AppSettingsManager()
    private init() {}

    private(set) var settings: AppSettings?

    var isLoaded: Bool { settings != nil }

    func loadSettings() async throws {
        let url = "\(Constant.baseUrl)master/app-settings"

        do {
            let wrapper: AppSettingsResponse = try await APIManager.shared.get(
                url,
                expectsWrappedResponse: false
            )
            self.settings = wrapper.data
            
            if let s = self.settings {
                UserCache.saveAccessKey(s.accessKey ?? "")
                UserCache.saveSecretKey(s.secretKey ?? "")
                UserCache.saveBucket(s.bucketName ?? "")
                UserCache.saveRegion(s.region ?? "")
                UserCache.saveFafsaLink(s.fafsaLink ?? "")
                UserCache.saveCasfaLink(s.casfaLink ?? "")
            }
        } catch {
            throw error
        }
    }
}

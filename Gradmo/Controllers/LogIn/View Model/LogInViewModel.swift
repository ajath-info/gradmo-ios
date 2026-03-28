//
//  LogInViewModel.swift
//  Gradmo
//

import Foundation
import Alamofire

final class LogInViewModel {

    func loginUser(
        username: String,
        password: String,
        userType: String,
        completion: @escaping (Result<GradmoLoginResponse, Error>) -> Void
    ) {
        let url = Constant.baseUrl + API.loginUserAPI
        let params: [String: Any] = [
            APIKeys.username: username,
            APIKeys.password: password,
            APIKeys.userType: userType,
            APIKeys.device_id: "",
            APIKeys.device_token: "",
            APIKeys.device_type: "ios"
        ]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        Task {
            do {
                let response: GradmoLoginResponse = try await APIManager.shared.post(
                    url,
                    parameters: params,
                    headers: headers,
                    expectsWrappedResponse: false
                )

                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func persistLoginSession(_ data: GradmoLoginUserData?, fallbackRole: UserRole) {
        let user = mapToLoginUser(data)
        UserCache.shared.saveUserDataWhenLogin(model: user, token: data?.accessToken)
        UserDefaults.standard.set(true, forKey: LoginKeys.isLoggedIn)
        UserCache.saveSelectedUserRole(mappedRole(from: data?.userType) ?? fallbackRole)
    }

    private func mapToLoginUser(_ data: GradmoLoginUserData?) -> LoginUser {
        let nameParts = (data?.name ?? "").split(separator: " ").map(String.init)
        let firstName = nameParts.first
        let lastName = nameParts.dropFirst().joined(separator: " ")

        return LoginUser(
            userID: data?.resolvedUserID,
            emailID: data?.email,
            isBlocked: nil,
            isVerified: nil,
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            state: nil,
            city: nil,
            countryCode: nil,
            phoneNumber: data?.mobile,
            address: nil,
            latitude: nil,
            longitude: nil,
            imageURL: data?.image,
            roleID: data?.role ?? data?.userType
        )
    }

    private func mappedRole(from backendUserType: String?) -> UserRole? {
        guard let backendUserType else { return nil }
        return UserRole(storageValue: backendUserType)
    }
}

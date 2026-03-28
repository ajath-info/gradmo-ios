//
//  SignupViewModel.swift
//  Gradmo
//

import Foundation
import Alamofire

final class SignupViewModel {

    func submitUserProfile(
        request: SignupUpsertRequest,
        completion: @escaping (Result<SignupUpsertResponse, Error>) -> Void
    ) {
        let url = Constant.baseUrl + API.signupUserAPI
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        Task {
            do {
                let response: SignupUpsertResponse = try await APIManager.shared.post(
                    url,
                    parameters: request.toParameters(),
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
}

//
//  CompleteProfileViewModel.swift
//  Gradmo
//

import Foundation
import Alamofire

final class CompleteProfileViewModel {

    func updateProfile(
        request: CompleteProfileUpdateProfileRequest,
        accessToken: String,
        fileParts: [MultipartFilePart] = [],
        completion: @escaping (Result<CompleteProfileUpdateProfileResponse, Error>) -> Void
    ) {
        let url = Constant.baseUrl + API.updateProfileAPI
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]

        Task {
            do {
                let response: CompleteProfileUpdateProfileResponse = try await APIManager.shared.uploadMultipart(
                    url,
                    parameters: request.toParameters(),
                    fileParts: fileParts,
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

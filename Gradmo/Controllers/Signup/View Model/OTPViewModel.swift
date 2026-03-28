//
//  OTPViewModel.swift
//  Gradmo
//

import Foundation
import Alamofire

final class OTPViewModel {

    func sendOTP(
        request: SendOTPRequest,
        completion: @escaping (Result<SendOTPResponse, Error>) -> Void
    ) {
        let url = Constant.baseUrl + API.sendOtpAPI
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        Task {
            do {
                let response: SendOTPResponse = try await APIManager.shared.post(
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

    func verifyOTP(
        request: VerifyOTPRequest,
        completion: @escaping (Result<VerifyOTPResponse, Error>) -> Void
    ) {
        let url = Constant.baseUrl + API.verifyOtpAPI
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        Task {
            do {
                let response: VerifyOTPResponse = try await APIManager.shared.post(
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

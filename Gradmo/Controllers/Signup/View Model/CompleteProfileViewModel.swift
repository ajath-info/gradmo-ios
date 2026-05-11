//
//  CompleteProfileViewModel.swift
//  Gradmo
//

import Foundation
import Alamofire

final class CompleteProfileViewModel {

    func fetchCountries(completion: @escaping (Result<CountryListResponse, Error>) -> Void) {
        let url = Constant.baseUrl + API.countryListAPI

        Task {
            do {
                let response: CountryListResponse = try await APIManager.shared.post(
                    url,
                    parameters: nil,
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

    func fetchStates(
        request: StateListRequest,
        completion: @escaping (Result<StateListResponse, Error>) -> Void
    ) {
        let url = Constant.baseUrl + API.stateListAPI

        Task {
            do {
                let response: StateListResponse = try await APIManager.shared.post(
                    url,
                    parameters: request.toParameters(),
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

    func fetchCities(
        request: CityListRequest,
        completion: @escaping (Result<CityListResponse, Error>) -> Void
    ) {
        let url = Constant.baseUrl + API.cityListAPI

        Task {
            do {
                let response: CityListResponse = try await APIManager.shared.post(
                    url,
                    parameters: request.toParameters(),
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

//
//  APIManager.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 04/09/25.
//

import Alamofire
import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}

    private func mergedHeaders(_ headers: HTTPHeaders?) -> HTTPHeaders {
        var finalHeaders: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        let token = UserCache1.authtoken()
        if !token.isEmpty {
            finalHeaders["Authorization"] = "Bearer \(token)"
        }

        headers?.forEach { header in
            finalHeaders[header.name] = header.value
        }

        return finalHeaders
    }

    func request<T: Decodable>(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil,
        expectsWrappedResponse: Bool = true
    ) async throws -> T {
        
        let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        
        do {
            let response = try await request.serializingData().response
            let statusCode = response.response?.statusCode ?? -1
            let data = response.data ?? Data()
            
            // 🔵 Log every API hit
            logAPI(
                url: url,
                method: method,
                statusCode: statusCode,
                requestBody: parameters,
                responseData: data,
                error: response.error
            )
            
            // Handle AFError if exists
            if let afError = response.error {
                if let urlError = afError.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                    throw NetworkError.noInternetConnection
                }
                throw NetworkError.requestFailed(afError.localizedDescription)
            }
            
            // Success case
            if (200..<300).contains(statusCode) {
                if expectsWrappedResponse {
                    let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                    guard apiResponse.status.lowercased() == "success", let result = apiResponse.data else {
                        throw NetworkError.apiError(apiResponse.message ?? "Unknown API error")
                    }
                    return result
                } else {
                    return try JSONDecoder().decode(T.self, from: data)
                }
            } else {
                // Non-200 status code: try to parse server error
                if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw NetworkError.validation(apiError)
                } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let message = json["error"] as? String {
                    throw NetworkError.apiError(message)
                } else {
                    let rawMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
                    throw NetworkError.apiError("Status \(statusCode): \(rawMessage)")
                }
            }
        } catch let urlError as URLError {
            // Handle URLError (e.g. offline)
            if urlError.code == .notConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.requestFailed(urlError.localizedDescription)
            }
        } catch {
            throw error // fallback for all other unexpected errors
        }
    }
    
    // MARK: - Convenience Methods
    func get<T: Decodable>(
        _ url: URLConvertible,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        expectsWrappedResponse: Bool = true
    ) async throws -> T {
        return try await request(
            url,
            method: .get,
            parameters: parameters,
            headers: mergedHeaders(headers),
            expectsWrappedResponse: expectsWrappedResponse
        )
    }

    func post<T: Decodable>(
        _ url: URLConvertible,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        expectsWrappedResponse: Bool = true
    ) async throws -> T {
        return try await request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: mergedHeaders(headers),
            expectsWrappedResponse: expectsWrappedResponse
        )
    }

    func delete<T: Decodable>(
        _ url: URLConvertible,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        expectsWrappedResponse: Bool = true // Add this parameter
    ) async throws -> T {
        return try await request(
            url,
            method: .delete,
            parameters: parameters,
            headers: mergedHeaders(headers),
            expectsWrappedResponse: expectsWrappedResponse
        )
    }
    func put<T: Decodable>(
        _ url: URLConvertible,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        expectsWrappedResponse: Bool = true // Add this parameter
    ) async throws -> T {
        return try await request(
            url,
            method: .put,
            parameters: parameters,
            headers: mergedHeaders(headers),
            expectsWrappedResponse: expectsWrappedResponse
        )
    }
    
    func patch<T: Decodable>(
        _ url: URLConvertible,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        return try await request(url, method: .patch, parameters: parameters, headers: headers)
    }

    func uploadMultipart<T: Decodable>(
        _ url: URLConvertible,
        parameters: [String: String],
        fileParts: [MultipartFilePart] = [],
        headers: HTTPHeaders? = nil,
        expectsWrappedResponse: Bool = true
    ) async throws -> T {
        let merged = mergedHeaders(headers)
        let request = AF.upload(
            multipartFormData: { multipartFormData in
                parameters.forEach { key, value in
                    multipartFormData.append(Data(value.utf8), withName: key)
                }

                fileParts.forEach { part in
                    multipartFormData.append(
                        part.data,
                        withName: part.name,
                        fileName: part.fileName,
                        mimeType: part.mimeType
                    )
                }
            },
            to: url,
            method: .post,
            headers: merged
        )

        do {
            let response = try await request.serializingData().response
            let statusCode = response.response?.statusCode ?? -1
            let data = response.data ?? Data()

            logAPI(
                url: url,
                method: .post,
                statusCode: statusCode,
                requestBody: parameters,
                responseData: data,
                error: response.error
            )

            if let afError = response.error {
                if let urlError = afError.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                    throw NetworkError.noInternetConnection
                }
                throw NetworkError.requestFailed(afError.localizedDescription)
            }

            if (200..<300).contains(statusCode) {
                if expectsWrappedResponse {
                    let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                    guard apiResponse.status.lowercased() == "success", let result = apiResponse.data else {
                        throw NetworkError.apiError(apiResponse.message ?? "Unknown API error")
                    }
                    return result
                } else {
                    return try JSONDecoder().decode(T.self, from: data)
                }
            } else {
                if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw NetworkError.validation(apiError)
                } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let message = json["error"] as? String {
                    throw NetworkError.apiError(message)
                } else {
                    let rawMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
                    throw NetworkError.apiError("Status \(statusCode): \(rawMessage)")
                }
            }
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                throw NetworkError.noInternetConnection
            } else {
                throw NetworkError.requestFailed(urlError.localizedDescription)
            }
        } catch {
            throw error
        }
    }
    
    func parseErrorMessage(_ data: Data?) -> String? {
        guard let data = data else { return nil }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = json["error"] as? String {
                return message
            }
        } catch {
            return nil
        }
        return nil
    }
    
    private func logAPI(
        url: URLConvertible,
        method: HTTPMethod,
        statusCode: Int?,
        requestBody: Parameters?,
        responseData: Data?,
        error: Error?
    ) {
        print("\n================= 🌐 API LOG START =================")
        print("➡️ URL: \(url)")
        print("➡️ Method: \(method.rawValue)")
        
        if let statusCode = statusCode {
            print("📡 Status Code: \(statusCode)")
        } else {
            print("📡 Status Code: N/A")
        }
        
        if let body = requestBody {
            print("📤 Request Body: \(body)")
        } else {
            print("📤 Request Body: NONE")
        }

        if let data = responseData,
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
            print("📥 Response JSON: \(json)")
        } else {
            print("📥 Response: EMPTY / INVALID JSON")
        }
        
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
        } else {
            print("✔️ No Error")
        }
        
        print("================= 🌐 API LOG END =================\n")
    }

}

struct MultipartFilePart {
    let name: String
    let fileName: String
    let mimeType: String
    let data: Data
}

struct APIErrorResponse: Decodable {
    let error: [FieldError]
    
    enum CodingKeys: String, CodingKey {
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the `error` string (which is actually a JSON array string)
        let errorString = try container.decode(String.self, forKey: .error)
        
        // Decode that string into actual [FieldError]
        let data = Data(errorString.utf8)
        self.error = try JSONDecoder().decode([FieldError].self, from: data)
    }
}

struct FieldError: Decodable {
    let code: String
    let expected: String?
    let received: String?
    let path: [String]
    let message: String
}

protocol RequestSender {
    func sendRequestWithStatus<T: Decodable>(apiURL: String, method: HTTPMethod, requestType: [String: Any]?, resultType: T.Type, IsAuthTokenAllowed: Bool) async throws -> (result: T?, status: Int)
}

import Foundation
import Alamofire

class APIService: RequestSender {
    
    static let shared = APIService()
    private let authToken: String?
    
    init() {
        authToken = UserDefaults.standard.string(forKey: "AuthToken")
    }
    
    func sendRequestWithStatus<T: Decodable>(
        apiURL: String,
        method: HTTPMethod,
        requestType: [String: Any]?,
        resultType: T.Type,
        IsAuthTokenAllowed: Bool
    ) async throws -> (result: T?, status: Int) {
        
        // Default headers
        var header: HTTPHeaders = ["Content-Type": "application/json"]

        if IsAuthTokenAllowed {
            let token = UserCache1.authtoken()
            header["Authorization"] = "Bearer \(token)"
        }

        debugPrint("🔗 Hitting URL: \(apiURL)")
        debugPrint("📌 Headers: \(header)")
        
        // ✅ Explicit generic types for request
        let request: DataRequest = AF.request(
            apiURL,
            method: method,
            parameters: (method == .get ? nil : requestType) as [String: Any]?,
            encoding: JSONEncoding.default as ParameterEncoding,
            headers: header
        )
        
        // ✅ Await response explicitly
        let response = await request.serializingDecodable(resultType).response
        let code = response.response?.statusCode ?? 500
        
        if [200, 405, 403, 201, 500, 400, 409, 401].contains(code) {
            return (result: response.value, status: code)
        } else {
            return (result: nil, status: code)
        }
    }
}

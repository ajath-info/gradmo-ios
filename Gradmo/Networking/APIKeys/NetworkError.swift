//
//  NetworkError.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 04/09/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(String)
    case decodingError(String)
    case apiError(String)
    case noInternetConnection
    case validation(APIErrorResponse)
}

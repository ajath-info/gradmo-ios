//
//  APIResponse.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 04/09/25.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let status: String
    let data: T?
    let message: String?
}

//
//  APIError.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import Foundation

enum APIError: LocalizedError {

    case invalidURL
    case invalidResponse
    case decodingError
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."

        case .invalidResponse:
            return "Received an unexpected response from the server."

        case .decodingError:
            return "Failed to read data from the server."

        case .networkError(let message):
            return message
        }
    }
}

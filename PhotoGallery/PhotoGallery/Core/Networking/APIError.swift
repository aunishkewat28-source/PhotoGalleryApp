//
//  APIError.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(code: Int)
    case decodingFailed
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpStatus(let code):
            return "The server responded with status code \(code)."
        case .decodingFailed:
            return "Unable to read the photo data from the server."
        case .networkUnavailable:
            return "Unable to connect. Please check your internet connection and try again."
        }
    }
}

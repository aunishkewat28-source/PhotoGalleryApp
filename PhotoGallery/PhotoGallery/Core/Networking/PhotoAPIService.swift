//
//  PhotoAPIService.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import Foundation

protocol PhotoAPIServiceProtocol {
    func fetchPhotos() async throws -> [PhotoDTO]
}

final class PhotoAPIService: PhotoAPIServiceProtocol {
    static let photosEndpoint = URL(string: "https://jsonplaceholder.typicode.com/photos")!

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchPhotos() async throws -> [PhotoDTO] {
        let url = Self.photosEndpoint

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            throw APIError.networkUnavailable
        } catch {
            throw APIError.networkUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpStatus(code: httpResponse.statusCode)
        }

        do {
            return try decoder.decode([PhotoDTO].self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

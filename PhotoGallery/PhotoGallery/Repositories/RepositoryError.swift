//
//  RepositoryError.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import Foundation

enum RepositoryError: LocalizedError, Equatable {
    case fetchFailed
    case saveFailed
    case deleteFailed
    case photoNotFound

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Unable to load photos from local storage."
        case .saveFailed:
            return "Unable to save photos to local storage."
        case .deleteFailed:
            return "Unable to delete the selected photo."
        case .photoNotFound:
            return "The selected photo could not be found."
        }
    }
}

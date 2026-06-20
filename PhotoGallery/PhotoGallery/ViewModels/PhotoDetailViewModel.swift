//
//  PhotoDetailViewModel.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 20/06/26.
//

import Combine
import Foundation
import os

@MainActor
final class PhotoDetailViewModel: ObservableObject {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PhotoGallery", category: "PhotoDetailViewModel")

    @Published var title = ""
    @Published private(set) var imageURL = ""
    @Published var errorMessage: String?
    @Published private(set) var isSaving = false
    @Published private(set) var isDeleting = false

    let photoID: Int64

    private let repository: PhotoRepositoryProtocol

    init(photoID: Int64, repository: PhotoRepositoryProtocol) {
        self.photoID = photoID
        self.repository = repository
        loadPhoto()
    }

    convenience init(photoID: Int64) {
        self.init(photoID: photoID, repository: PhotoRepository())
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    func saveTitle() -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            errorMessage = "Title cannot be empty."
            return false
        }

        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        do {
            try repository.updateTitle(id: photoID, title: trimmedTitle)
            title = trimmedTitle
            return true
        } catch {
            applyError(error)
            return false
        }
    }

    func deletePhoto() -> Bool {
        isDeleting = true
        errorMessage = nil

        defer { isDeleting = false }

        do {
            try repository.deletePhoto(id: photoID)
            return true
        } catch {
            applyError(error)
            return false
        }
    }

    private func loadPhoto() {
        do {
            guard let photo = try repository.fetchPhoto(id: photoID) else {
                errorMessage = RepositoryError.photoNotFound.errorDescription
                Self.logger.error("Photo not found for id \(self.photoID)")
                return
            }

            title = photo.title ?? ""
            imageURL = photo.url ?? ""
        } catch {
            applyError(error)
        }
    }

    private func applyError(_ error: Error) {
        Self.logger.error("Photo detail error: \(error.localizedDescription, privacy: .public)")
        errorMessage = Self.message(for: error)
    }

    private static func message(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }

        return "Something went wrong. Please try again."
    }
}

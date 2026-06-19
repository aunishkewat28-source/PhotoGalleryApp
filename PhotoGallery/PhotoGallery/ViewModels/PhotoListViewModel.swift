//
//  PhotoListViewModel.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import Combine
import CoreData
import Foundation

@MainActor
final class PhotoListViewModel: ObservableObject {
    static let defaultPageSize = 30

    @Published private(set) var photos: [Photo] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingNextPage = false
    @Published var errorMessage: String?
    @Published private(set) var hasMorePages = true

    private let repository: PhotoRepositoryProtocol
    private let pageSize: Int
    private var currentPage = 0
    private var totalCount = 0

    init(repository: PhotoRepositoryProtocol, pageSize: Int = 30) {
        self.repository = repository
        self.pageSize = pageSize
    }

    convenience init() {
        self.init(repository: PhotoRepository(), pageSize: Self.defaultPageSize)
    }

    func loadInitialData() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await repository.loadPhotosIfNeeded()
            try reloadFirstPage()
        } catch {
            applyError(error)
        }
    }

    func loadNextPageIfNeeded(currentItem: Photo) {
        guard hasMorePages,
              !isLoading,
              !isLoadingNextPage,
              let lastPhoto = photos.last,
              lastPhoto.objectID == currentItem.objectID else {
            return
        }

        Task {
            await loadNextPage()
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private

    private func loadNextPage() async {
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            let nextPage = currentPage + 1
            let newPhotos = try repository.fetchPhotos(page: nextPage, pageSize: pageSize)

            guard !newPhotos.isEmpty else {
                hasMorePages = false
                return
            }

            currentPage = nextPage
            photos.append(contentsOf: newPhotos)
            hasMorePages = photos.count < totalCount
        } catch {
            applyError(error)
        }
    }

    private func reloadFirstPage() throws {
        totalCount = try repository.totalPhotoCount()
        currentPage = 0
        photos = try repository.fetchPhotos(page: 0, pageSize: pageSize)
        hasMorePages = photos.count < totalCount
    }

    private func applyError(_ error: Error) {
        errorMessage = Self.message(for: error)

        if photos.isEmpty {
            hasMorePages = false
        }
    }

    private static func message(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }

        return "Something went wrong. Please try again."
    }
}

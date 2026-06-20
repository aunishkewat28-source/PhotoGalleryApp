//
//  PhotoListViewModel.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import Combine
import CoreData
import Foundation
import os

@MainActor
final class PhotoListViewModel: ObservableObject {
    static let defaultPageSize = 30
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PhotoGallery", category: "PhotoListViewModel")

    @Published private(set) var photos: [Photo] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingNextPage = false
    @Published var errorMessage: String?
    @Published private(set) var hasMorePages = true
    @Published private(set) var listUpdateToken = UUID()

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

    func retry() async {
        await loadInitialData()
    }

    var showsEmptyState: Bool {
        !isLoading && photos.isEmpty
    }

    var emptyStateTitle: String {
        errorMessage == nil ? "No Photos Available" : "Unable to Load Photos"
    }

    var emptyStateMessage: String {
        errorMessage ?? "There are no photos to display yet."
    }

    var emptyStateSystemImage: String {
        errorMessage == nil ? "photo.on.rectangle.angled" : "wifi.exclamationmark"
    }

    var showsRetryButton: Bool {
        errorMessage != nil
    }

    func updatePhotoTitle(id: Int64, title _: String) {
        guard photos.contains(where: { $0.id == id }) else { return }

        do {
            try reloadLoadedPages()
        } catch {
            applyError(error)
        }
    }

    func deletePhoto(id: Int64) {
        do {
            try repository.deletePhoto(id: id)
            removePhotoFromList(id: id)
        } catch {
            applyError(error)
        }
    }

    func removePhotoFromList(id: Int64) {
        photos.removeAll { $0.id == id }
        totalCount = max(0, totalCount - 1)
        hasMorePages = photos.count < totalCount
        notifyListDidChange()
    }

    // MARK: - Private

    private func reloadLoadedPages() throws {
        var reloadedPhotos: [Photo] = []

        if currentPage >= 0 {
            for page in 0...currentPage {
                reloadedPhotos.append(contentsOf: try repository.fetchPhotos(page: page, pageSize: pageSize))
            }
        }

        photos = reloadedPhotos
        totalCount = try repository.totalPhotoCount()
        hasMorePages = photos.count < totalCount
        notifyListDidChange()
    }

    private func notifyListDidChange() {
        listUpdateToken = UUID()
    }

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
        Self.logger.error("Photo list error: \(error.localizedDescription, privacy: .public)")
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

//
//  PhotoRepository.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import CoreData
import Foundation

protocol PhotoRepositoryProtocol {
    func loadPhotosIfNeeded() async throws
    func fetchPhotos(page: Int, pageSize: Int) throws -> [Photo]
    func totalPhotoCount() throws -> Int
    func fetchPhoto(id: Int64) throws -> Photo?
    func updateTitle(id: Int64, title: String) throws
    func deletePhoto(id: Int64) throws
}

final class PhotoRepository: PhotoRepositoryProtocol {
    static let defaultPageSize = 30

    private let persistenceController: PersistenceController
    private let apiService: PhotoAPIServiceProtocol

    private var viewContext: NSManagedObjectContext {
        persistenceController.viewContext
    }

    init(
        persistenceController: PersistenceController = .shared,
        apiService: PhotoAPIServiceProtocol = PhotoAPIService()
    ) {
        self.persistenceController = persistenceController
        self.apiService = apiService
    }

    /// Loads from Core Data when data exists; otherwise fetches from the API and persists.
    func loadPhotosIfNeeded() async throws {
        let existingCount = try totalPhotoCount()
        guard existingCount == 0 else { return }

        let photos = try await apiService.fetchPhotos()
        try await savePhotos(from: photos)
    }

    func fetchPhotos(page: Int, pageSize: Int = defaultPageSize) throws -> [Photo] {
        guard page >= 0, pageSize > 0 else { return [] }

        let request = Photo.fetchRequestSortedByID()
        request.fetchOffset = page * pageSize
        request.fetchLimit = pageSize

        do {
            return try viewContext.fetch(request)
        } catch {
            throw RepositoryError.fetchFailed
        }
    }

    func totalPhotoCount() throws -> Int {
        let request = NSFetchRequest<Photo>(entityName: "Photo")

        do {
            return try viewContext.count(for: request)
        } catch {
            throw RepositoryError.fetchFailed
        }
    }

    func fetchPhoto(id: Int64) throws -> Photo? {
        let request = Photo.fetchRequest(forID: id)

        do {
            return try viewContext.fetch(request).first
        } catch {
            throw RepositoryError.fetchFailed
        }
    }

    func updateTitle(id: Int64, title: String) throws {
        guard let photo = try fetchPhoto(id: id) else {
            throw RepositoryError.photoNotFound
        }

        photo.title = title

        do {
            try persistenceController.save()
        } catch {
            viewContext.rollback()
            throw RepositoryError.saveFailed
        }
    }

    func deletePhoto(id: Int64) throws {
        guard let photo = try fetchPhoto(id: id) else {
            throw RepositoryError.photoNotFound
        }

        viewContext.delete(photo)

        do {
            try persistenceController.save()
        } catch {
            viewContext.rollback()
            throw RepositoryError.deleteFailed
        }
    }

    // MARK: - Private

    private func savePhotos(from dtos: [PhotoDTO]) async throws {
        let backgroundContext = persistenceController.newBackgroundContext()

        do {
            try await backgroundContext.perform {
                for dto in dtos {
                    try self.upsertPhoto(from: dto, in: backgroundContext)
                }

                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            }
        } catch {
            throw RepositoryError.saveFailed
        }
    }

    private func upsertPhoto(from dto: PhotoDTO, in context: NSManagedObjectContext) throws {
        let request = Photo.fetchRequest(forID: Int64(dto.id))
        let photo = try context.fetch(request).first ?? Photo(context: context)

        photo.id = Int64(dto.id)
        photo.albumId = Int64(dto.albumId)
        photo.title = dto.title
        photo.url = dto.url
        photo.thumbnailUrl = dto.thumbnailUrl
    }
}

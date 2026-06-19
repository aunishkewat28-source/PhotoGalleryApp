//
//  ImageCache.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import UIKit

protocol ImageCaching: Sendable {
    func image(for url: URL) async -> UIImage?
}

actor ImageCache: ImageCaching {
    static let shared = ImageCache()

    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()
    private var inFlightTasks: [URL: Task<UIImage?, Never>] = [:]
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func image(for url: URL) async -> UIImage? {
        let cacheKey = url.absoluteString as NSString

        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }

        if let existingTask = inFlightTasks[url] {
            return await existingTask.value
        }

        let downloadTask = Task<UIImage?, Never> {
            await downloadImage(from: url, cacheKey: cacheKey)
        }

        inFlightTasks[url] = downloadTask
        let image = await downloadTask.value
        inFlightTasks[url] = nil
        return image
    }

    private func downloadImage(from url: URL, cacheKey: NSString) async -> UIImage? {
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let image = UIImage(data: data) else {
                return nil
            }

            let cost = data.count
            cache.setObject(image, forKey: cacheKey, cost: cost)
            return image
        } catch {
            return nil
        }
    }
}

//
//  AsyncThumbnailImage.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import SwiftUI

struct AsyncThumbnailImage: View {
    let urlString: String
    var contentMode: ContentMode = .fill

    @State private var loadedImage: UIImage?
    @State private var didFail = false

    init(urlString: String, contentMode: ContentMode = .fill) {
        self.urlString = urlString
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if didFail {
                defaultImage
            } else {
                loadingPlaceholder
            }
        }
        .task(id: urlString) {
            await loadImage()
        }
    }

    private var loadingPlaceholder: some View {
        ZStack {
            Color.gray.opacity(0.15)
            ProgressView()
        }
    }

    private var defaultImage: some View {
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }

    private func loadImage() async {
        loadedImage = nil
        didFail = false

        guard let url = URL(string: urlString) else {
            didFail = true
            return
        }

        if let image = await ImageCache.shared.image(for: url) {
            loadedImage = image
        } else {
            didFail = true
        }
    }
}

#Preview {
    AsyncThumbnailImage(urlString: "https://via.placeholder.com/150")
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
}

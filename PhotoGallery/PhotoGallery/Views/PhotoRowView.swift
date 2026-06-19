//
//  PhotoRowView.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import CoreData
import SwiftUI

struct PhotoRowView: View {
    let photo: Photo

    var body: some View {
        HStack(spacing: 12) {
            AsyncThumbnailImage(urlString: photo.thumbnailUrl ?? "")
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(photo.title ?? "Untitled")
                .font(.body)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = PersistenceController.preview.viewContext
    let photo = Photo(context: context)
    photo.id = 1
    photo.title = "Sample photo title for preview"
    photo.thumbnailUrl = "https://via.placeholder.com/150"

    return PhotoRowView(photo: photo)
        .padding()
}

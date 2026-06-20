//
//  EmptyStateView.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 20/06/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var showsRetry: Bool = false
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if showsRetry, let retryAction {
                Button("Try Again", action: retryAction)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview("Empty") {
    EmptyStateView(
        title: "No Photos Available",
        message: "There are no photos to display yet.",
        systemImage: "photo.on.rectangle.angled"
    )
}

#Preview("Error") {
    EmptyStateView(
        title: "Unable to Load Photos",
        message: "Unable to connect. Please check your internet connection and try again.",
        systemImage: "wifi.exclamationmark",
        showsRetry: true,
        retryAction: {}
    )
}

//
//  PhotoListView.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import SwiftUI

struct PhotoListView: View {
    @StateObject private var viewModel = PhotoListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.photos.isEmpty {
                    loadingView
                } else {
                    photoList
                }
            }
            .navigationTitle("Photos")
            .task {
                await viewModel.loadInitialData()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading photos...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var photoList: some View {
        List {
            ForEach(viewModel.photos, id: \.objectID) { photo in
                PhotoRowView(photo: photo)
                    .onAppear {
                        viewModel.loadNextPageIfNeeded(currentItem: photo)
                    }
            }

            if viewModel.isLoadingNextPage {
                paginationFooter
            }
        }
        .listStyle(.plain)
    }

    private var paginationFooter: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    PhotoListView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}

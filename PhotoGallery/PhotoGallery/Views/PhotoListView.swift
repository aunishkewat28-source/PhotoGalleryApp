//
//  PhotoListView.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import CoreData
import SwiftUI

struct PhotoListView: View {
    @StateObject private var viewModel = PhotoListViewModel()

    @State private var photoPendingDeletion: Photo?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.photos.isEmpty {
                    loadingView
                } else if viewModel.showsEmptyState {
                    emptyStateView
                } else {
                    photoList
                }
            }
            .navigationTitle("Photos")
            .task {
                await viewModel.loadInitialData()
            }
            .alert("Delete Photo", isPresented: $showDeleteConfirmation, presenting: photoPendingDeletion) { photo in
                Button("Delete", role: .destructive) {
                    viewModel.deletePhoto(id: photo.id)
                    photoPendingDeletion = nil
                }
                Button("Cancel", role: .cancel) {
                    photoPendingDeletion = nil
                }
            } message: { _ in
                Text("Are you sure you want to delete this photo? This action cannot be undone.")
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.clearError()
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
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

    private var emptyStateView: some View {
        EmptyStateView(
            title: viewModel.emptyStateTitle,
            message: viewModel.emptyStateMessage,
            systemImage: viewModel.emptyStateSystemImage,
            showsRetry: viewModel.showsRetryButton,
            retryAction: {
                Task {
                    await viewModel.retry()
                }
            }
        )
    }

    private var photoList: some View {
        List {
            ForEach(viewModel.photos, id: \.objectID) { photo in
                NavigationLink {
                    PhotoDetailView(
                        photoID: photo.id,
                        onTitleSaved: { id, title in
                            viewModel.updatePhotoTitle(id: id, title: title)
                        },
                        onPhotoDeleted: { id in
                            viewModel.removePhotoFromList(id: id)
                        }
                    )
                } label: {
                    PhotoRowView(photo: photo)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        photoPendingDeletion = photo
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .onAppear {
                    viewModel.loadNextPageIfNeeded(currentItem: photo)
                }
            }

            if viewModel.isLoadingNextPage {
                paginationFooter
            }
        }
        .listStyle(.plain)
        .id(viewModel.listUpdateToken)
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

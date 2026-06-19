//
//  PhotoDetailView.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 20/06/26.
//

import SwiftUI

struct PhotoDetailView: View {
    @StateObject private var viewModel: PhotoDetailViewModel
    @Environment(\.dismiss) private var dismiss

    private let onTitleSaved: ((Int64, String) -> Void)?

    init(photoID: Int64, onTitleSaved: ((Int64, String) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: PhotoDetailViewModel(photoID: photoID))
        self.onTitleSaved = onTitleSaved
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncThumbnailImage(urlString: viewModel.imageURL, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("Enter photo title", text: $viewModel.title)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding()
        }
        .navigationTitle("Edit Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveAndDismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func saveAndDismiss() {
        guard viewModel.saveTitle() else { return }
        onTitleSaved?(viewModel.photoID, viewModel.title)
        dismiss()
    }
}

#Preview {
    NavigationView {
        PhotoDetailView(photoID: 1)
    }
    .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}

//
//  PhotoGalleryApp.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import SwiftUI

@main
struct PhotoGalleryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            PhotoListView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

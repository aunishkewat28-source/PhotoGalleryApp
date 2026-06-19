//
//  PersistenceController.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        for index in 1...5 {
            let photo = Photo(context: context)
            photo.id = Int64(index)
            photo.albumId = 1
            photo.title = "Preview photo \(index)"
            photo.url = "https://via.placeholder.com/600"
            photo.thumbnailUrl = "https://via.placeholder.com/150"
        }

        try? controller.save()
        return controller
    }()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PhotoGallery")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() throws {
        let context = container.viewContext
        guard context.hasChanges else { return }
        try context.save()
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}

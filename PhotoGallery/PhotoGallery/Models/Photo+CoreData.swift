//
//  Photo+CoreData.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import CoreData

extension Photo {
    static func fetchRequestSortedByID() -> NSFetchRequest<Photo> {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Photo.id, ascending: true)]
        return request
    }

    static func fetchRequest(forID id: Int64) -> NSFetchRequest<Photo> {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.predicate = NSPredicate(format: "id == %lld", id)
        request.fetchLimit = 1
        return request
    }
}

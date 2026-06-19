//
//  PhotoDTO.swift
//  PhotoGallery
//
//  Created by Aunish Jayprakash Kewat on 19/06/26.
//

import Foundation

struct PhotoDTO: Codable, Identifiable, Equatable {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}

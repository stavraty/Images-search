//
//  PixabayResponse.swift
//  Images search
//
//  Created by AS on 14.07.2023.
//

import Foundation

struct PixabayResponse: Codable {
    let total: Int
    let totalHits: Int
    let hits: [Image]
    
    struct Image: Codable {
        let id: Int
        let pageURL: String
        let tags: String
        let previewURL: String
        let webformatURL: String
        let largeImageURL: String
        let imageWidth: Int
        let imageHeight: Int
        let imageSize: Int
        let views: Int
        let downloads: Int
        let likes: Int
        let comments: Int
        let user: String
        let userImageURL: String
    }
}

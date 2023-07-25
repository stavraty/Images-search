//
//  SearchManager.swift
//  Images search
//
//  Created by AS on 17.07.2023.
//

import UIKit

class SearchManager {
    
    private let api = APIService()
    
    var images: [PixabayResponse.Image] = []
    var currentPage = 1
    var filters = Set<String>()
    var query: String?
    var imageType: String?
    
    func fetchImages(query: String, imageType: String, completion: @escaping () -> Void) {
        self.query = query
        self.imageType = imageType
        fetchNextPage(completion: completion)
    }
    
    func fetchNextPage(completion: @escaping () -> Void) {
        guard let query = query, let imageType = imageType else {
            return
        }
        
        api.fetchImages(query: query, imageType: imageType, page: currentPage) { [weak self] result in
            switch result {
            case .success(let pixabayResponse):
                self?.images.append(contentsOf: pixabayResponse.hits)
                self?.currentPage += 1
                for image in pixabayResponse.hits {
                    self?.filters.insert(image.tags)
                }
                DispatchQueue.main.async {
                    completion()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

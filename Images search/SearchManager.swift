//
//  SearchManager.swift
//  Images search
//
//  Created by AS on 17.07.2023.
//

//import Foundation
//
//class SearchManager {
//
//    var searchQuery: String = ""
//    var imageType: String = ""
//
//    func fetchImages(completion: @escaping (Result<[PixabayResponse.Image], Error>) -> Void) {
//        let api = APIService()
//        api.fetchImages(query: searchQuery, imageType: imageType) { result in
//            switch result {
//            case .success(let pixabayResponse):
//                completion(.success(pixabayResponse.hits))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//}

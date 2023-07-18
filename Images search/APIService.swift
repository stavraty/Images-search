//
//  APIService.swift
//  Images search
//
//  Created by AS on 14.07.2023.
//

import Foundation

class APIService {
    
    private let apiKey = "1461007-d09f3a409d0a4d2345817fec2"
    
    func fetchImages(query: String, imageType: String, page: Int, completion: @escaping (Result<PixabayResponse, Error>) -> Void) {
        let urlString = "https://pixabay.com/api/?key=\(apiKey)&q=\(query)&image_type=\(imageType)&page=\(page)"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let decoder = JSONDecoder()
                do {
                    let imagesResponse = try decoder.decode(PixabayResponse.self, from: data)
                    completion(.success(imagesResponse))
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            }
        }.resume()
    }
}

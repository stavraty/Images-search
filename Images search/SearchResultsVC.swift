//
//  SearchResultsVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

class SearchResultsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let api = APIService()
    private var images: [PixabayResponse.Image] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func fetchImages(query: String, imageType: String) {
        api.fetchImages(query: query, imageType: imageType) { [weak self] result in
            switch result {
            case .success(let pixabayResponse):
                self?.images = pixabayResponse.hits
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGridCell", for: indexPath) as! ImageGridCell
        let imageURL = URL(string: images[indexPath.row].webformatURL)!
        ImageCacheService.shared.loadImage(url: imageURL) { (image) in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    @IBAction func goHomeButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

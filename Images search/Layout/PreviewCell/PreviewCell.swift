//
//  PreviewCell.swift
//  Images search
//
//  Created by AS on 26.07.2023.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var previewURL: URL?
    private var largeImageURL: URL?
    weak var imagePageVC: ImagePageVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
//        self.addGestureRecognizer(tapGestureRecognizer)
    }

    func setImage(with previewURL: URL, largeImageURL: URL) {
        self.previewURL = previewURL
        self.largeImageURL = largeImageURL
        activityIndicator.startAnimating()
        imageView.sd_setImage(with: previewURL, completed: { [weak self] (image, error, cacheType, imageURL) in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
            } else {
                self?.activityIndicator.stopAnimating()
            }
        })
    }
    
//    func cellTapped() {
//        if let largeImageURL = largeImageURL {
//            imagePageVC?.handleCellTap(with: largeImageURL)
//        }
//    }
//
//    @objc func handleCellTap() {
//        cellTapped()
//    }
}

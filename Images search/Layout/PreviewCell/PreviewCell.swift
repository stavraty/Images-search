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
    
    private var previewURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setImage(with previewURL: URL) {
        activityIndicator.startAnimating()
        imageView.sd_setImage(with: previewURL, completed: { [weak self] (image, error, cacheType, imageURL) in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
            } else {
                self?.activityIndicator.stopAnimating()
            }
        })
    }
}

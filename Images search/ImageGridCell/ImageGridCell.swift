//
//  ImageGridCell.swift
//  Images search
//
//  Created by AS on 18.07.2023.
//

import UIKit

class ImageGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setImage(with url: URL) {
        activityIndicator.startAnimating()
        imageView.sd_setImage(with: url) { [weak self] (_, _, _, _) in
            self?.activityIndicator.stopAnimating()
        }
    }
}

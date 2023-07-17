//
//  ImageGridCell.swift
//  Images search
//
//  Created by AS on 17.07.2023.
//

import UIKit

class ImageGridCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

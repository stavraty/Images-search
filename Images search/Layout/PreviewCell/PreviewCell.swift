//
//  PreviewCell.swift
//  Images search
//
//  Created by AS on 26.07.2023.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var previewURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setImage(with previewURL: URL) {
        // Використовуйте бібліотеку SDWebImage для завантаження та кешування зображення з URL.
        imageView.sd_setImage(with: previewURL, completed: { [weak self] (image, error, cacheType, imageURL) in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
            } else {
                // Зображення успішно завантажено та встановлено, тут ви можете виконати додаткові дії, якщо потрібно.
            }
        })
    }
}

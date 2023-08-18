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
    @IBOutlet weak var shareButton: UIButton!
    
    static let identifier = "ImageGridCell"
    static let nibName = "ImageGridCell"

    private var pageURL: String?
    private var largeImageURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
        setUp()
    }
    
    func setUp() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    func setImage(with url: URL, pageURL: String, largeImageURL: String?, showShareButton: Bool) {
        hideShareButton()
        activityIndicator.startAnimating()
        self.pageURL = pageURL
        self.largeImageURL = largeImageURL
        imageView.sd_setImage(with: url) { [weak self] (_, _, _, _) in
            self?.activityIndicator.stopAnimating()
            if showShareButton {
                self?.showShareButton()
            }
        }
    }
    
    func hideShareButton() {
        shareButton.isHidden = true
    }
    
    func showShareButton() {
        shareButton.isHidden = false
    }
    
    func setupButton() {
        shareButton.setTitle("", for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    @objc private func shareButtonTapped() {
        guard let pageURL = pageURL, let url = URL(string: pageURL) else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

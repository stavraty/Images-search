//
//  ImagePageVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

class ImagePageVC: BaseVC {
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var largeImageURL: URL?
    private let imageCacheService = ImageCacheService.shared
    private var currentScale: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        
        zoomButton.setTitle("", for: .normal)
        shareButton.layer.cornerRadius = 5
        shareButton.clipsToBounds = true
        shareButton.layer.borderWidth = 1.0
        shareButton.layer.borderColor = UIColor(red: 0.26, green: 0.04, blue: 0.88, alpha: 1.00).cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        loadLargeImage()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }
    
    private func loadLargeImage() {
        guard let imageURL = largeImageURL else {
            return
        }
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        imageCacheService.loadImage(url: imageURL) { [weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.selectedImage.image = image
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                }
            } else {
                print("Не вдалося завантажити зображення з URL: \(imageURL)")
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
            }
        }
    }
    
    @IBAction func zoomButtonTapped(_ sender: Any) {
        print(largeImageURL)
//        currentScale = min(currentScale + 2.0, 10.0)
//        updateImageScale()
    }
    
    private func updateImageScale() {
        guard let originalImage = selectedImage.image else {
            return
        }
        
        let scaledImage = scaleImage(originalImage, scale: currentScale)
        selectedImage.image = scaledImage
    }
    
    private func scaleImage(_ image: UIImage, scale: CGFloat) -> UIImage? {
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

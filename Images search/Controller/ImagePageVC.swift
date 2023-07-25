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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageZoomViewSegue" {
            if let destinationVC = segue.destination as? ImageZoomVC {
                // destinationVC.zoomedImage = selectedImage.image
                destinationVC.largeImageURL = largeImageURL
            }
        }
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
        performSegue(withIdentifier: "showImageZoomViewSegue", sender: nil)
    }
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let imageURL = largeImageURL else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [imageURL], applicationActivities: nil)
        if let presenter = UIApplication.shared.windows.first?.rootViewController {
            presenter.present(activityViewController, animated: true, completion: nil)
        }
    }
    
}

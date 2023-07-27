//
//  ImagePageVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit
import Photos

class ImagePageVC: BaseVC {
    
    @IBOutlet weak var selectedImage: UIImageView!
    //@IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoFormatLabel: UILabel!
    @IBOutlet weak var previewCollectionView: UICollectionView!
    
    var largeImageURL: URL?
    private let imageCacheService = ImageCacheService.shared
    private var previews: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupButtons()
        updatePhotoFormatLabel()
        registerCells()
        setupPreviewCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        loadLargeImage()
        // loadPreviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageZoomViewSegue" {
            if let destinationVC = segue.destination as? ImageZoomVC {
                destinationVC.largeImageURL = largeImageURL
            }
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }
    
    private func setupButtons() {
        zoomButton.setTitle("", for: .normal)
        shareButton.layer.cornerRadius = 5
        shareButton.clipsToBounds = true
        shareButton.layer.borderWidth = 1.0
        shareButton.layer.borderColor = UIColor(red: 0.26, green: 0.04, blue: 0.88, alpha: 1.00).cgColor
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
    
    private func getImageFormat(from url: URL) -> String? {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
            case "jpg", "jpeg":
                return "JPG"
            case "png":
                return "PNG"
            default:
                return nil
        }
    }
    
    private func updatePhotoFormatLabel() {
        guard let imageURL = largeImageURL, let format = getImageFormat(from: imageURL) else {
            return
        }
        
        let labelText = "Photo in .\(format) format"
        photoFormatLabel.text = labelText
    }
    
    private func downloadAndSaveImage(from imageURL: URL) {
        URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
            DispatchQueue.main.async {

                if let error = error {
                    print("Failed to download the image: \(error)")
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    print("Invalid image data")
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { [weak self] success, error in
                    if success {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Success", message: "Image saved to the gallery.")
                        }
                    } else {
                        print("Failed to save the image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }.resume()
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func registerCells() {
        previewCollectionView.register(UINib(nibName: "PreviewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewCell")
    }
    
    private func setupPreviewCollectionView() {
        previewCollectionView.dataSource = self
        previewCollectionView.delegate = self
        previewCollectionView.register(UINib(nibName: "PreviewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewCell")
    }
    
//    private func loadPreviews() {
//        // Завантаження попередніх зображень з відповідних URL
//        previews = [...] // Ваші URL попередніх зображень
//        previewCollectionView.reloadData()
//    }

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
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        guard let imageURL = largeImageURL else {
            return
        }
        downloadAndSaveImage(from: imageURL)
    }
}

extension ImagePageVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell
        let previewURL = previews[indexPath.item]
        cell?.setImage(with: previewURL)
        return cell ?? UICollectionViewCell()
    }
}

extension ImagePageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Виконайте код, що пов'язаний з обробкою натискання на комірку
        let selectedPreviewURL = previews[indexPath.item]
        // Додайте вашу логіку для обробки натискання на попереднє зображення
    }
}

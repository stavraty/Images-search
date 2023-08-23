//
//  ImagePageVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit
import Photos

class ImagePageViewController: BaseViewController {
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoFormatLabel: UILabel!
    @IBOutlet weak var previewCollectionView: UICollectionView!
    @IBOutlet weak var downloadButton: UIButton!
    
    private let imageCacheService = ImageCacheService.shared
    private var selectedImageIndex: Int = 0
    private var largeImageURLs: [URL] = []
    private var selectedImageURL: URL?
    private var isImageLoaded = false
    private let imageZoomSegueIdentifier = "showImageZoomViewSegue"
    private let searchResultsViewControllerIdentifier = "SearchResultsViewController"
    private var estimateWidth = 95.0
    private var cellMarginSize = 16.0
    private let defaultCornerRadius = 5
    private let defaultBorderWidth = 1.0
    private let defaultBorderColor = UIColor(red: 0.26, green: 0.04, blue: 0.88, alpha: 1.00).cgColor
    
    var relatedImagesCollectionView: UICollectionView?
    var largeImageURL: URL?
    var pageURL: URL?
    var selectedImageFromGallery: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        setupButtons()
        updatePhotoFormatLabel()
        setupPreviewCollectionView()
        setupGridView()
        
        searchTF.delegate = self
        selectedImage.image = selectedImageFromGallery
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if let url = largeImageURL {
            selectedImageIndex = largeImageURLs.firstIndex(of: url) ?? 0
            loadLargeImage(withURL: url)
        }
    }
    
    override func setupGridView() {
        let flow = previewCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        let width = self.calculateWith()
        flow.estimatedItemSize = CGSize(width: width, height: width)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == imageZoomSegueIdentifier {
            if let destinationVC = segue.destination as? ImageZoomViewController, let imageURL = sender as? URL {
                destinationVC.largeImageURL = imageURL
                destinationVC.selectedImageURL = selectedImageURL
            }
        }
    }
    
    func loadLargeImage(withURL url: URL) {
        selectedImageURL = url
        isActivityIndicatorActive(true)
        
        imageCacheService.loadImage(url: url) { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    self?.selectedImage.image = image
                    self?.isActivityIndicatorActive(false)
                    self?.isImageLoaded = true
                } else {
                    let errorMessage = "Failed to load image from URL: \(url)"
                    self?.showAlert(title: "Error", message: errorMessage)
                    self?.isActivityIndicatorActive(false)
                    self?.isImageLoaded = false
                }
            }
        }
    }
    
    func isActivityIndicatorActive(_ activate: Bool) {
        if activate {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.isHidden = !activate
    }
    
    private func navigateToSearchResultsVC(with searchText: String, imageType: String?) {
        if let searchResultsVC = storyboard?.instantiateViewController(withIdentifier: searchResultsViewControllerIdentifier) as? SearchResultsViewController {
            searchResultsVC.searchQuery = searchText
            searchResultsVC.imageType = imageType
            searchResultsVC.searchText = searchText
            navigationController?.pushViewController(searchResultsVC, animated: true)
        }
    }
    
    private func calculateWith() -> CGFloat {
        let estimateWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        return width
    }
    
    private func setupActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }
    
    private func setupButtons() {
        zoomButton.setTitle("", for: .normal)
        editImageButton.setTitle("", for: .normal)
        shareButton.layer.cornerRadius = CGFloat(defaultCornerRadius)
        shareButton.clipsToBounds = true
        shareButton.layer.borderWidth = defaultBorderWidth
        shareButton.layer.borderColor = defaultBorderColor
    }
    
    private func updatePhotoFormatLabel() {
        guard let imageURL = largeImageURL, let format = getImageFormat(from: imageURL) else {
            return
        }
        
        let labelText = "Photo in .\(format) format"
        photoFormatLabel.text = labelText
    }
    
    
    private func setupPreviewCollectionView() {
        previewCollectionView.dataSource = self
        previewCollectionView.delegate = self
        previewCollectionView.register(UINib(nibName: ImageGridCell.nibName, bundle: nil), forCellWithReuseIdentifier: ImageGridCell.identifier)
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
    
    private func updatePhotoFormatLabel(imageURL: URL) {
        if let format = getImageFormat(from: imageURL) {
            let labelText = "Photo in .\(format) format"
            photoFormatLabel.text = labelText
        }
    }
    
    private func zoomToSelectedImage(imageURL: URL) {
        guard let currentSelectedImageURL = selectedImageURL, currentSelectedImageURL != imageURL else {
            return
        }
        selectedImageURL = imageURL
        zoomButtonTapped(self)
    }
    
    private func downloadAndSaveImage(from imageURL: URL) {
        URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                
                if let error = error {
                    let errorMessage = "Failed to download the image: \(error)"
                    self?.showAlert(title: "Error", message: errorMessage)
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    let errorMessage = "Invalid image data"
                    self?.showAlert(title: "Error", message: errorMessage)
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
                        let errorMessage = "Failed to save the image: \(error?.localizedDescription ?? "Unknown error")"
                        self?.showAlert(title: "Error", message: errorMessage)
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
    
    @IBAction func editImageButtonTapped(_ sender: Any) {
        guard let selectedImage = selectedImage.image else {
            return
        }
        
        let imageEditVC = ImageEditViewController()
        imageEditVC.imageToEdit = selectedImage
        self.navigationController?.pushViewController(imageEditVC, animated: true)
    }
    
    @IBAction func zoomButtonTapped(_ sender: Any) {
        guard isImageLoaded, let imageURL = selectedImageURL else {
            return
        }
        performSegue(withIdentifier: imageZoomSegueIdentifier, sender: imageURL)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let imageURL = selectedImageURL,
              let presenter = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [imageURL], applicationActivities: nil)
        presenter.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        guard let imageURL = selectedImageURL else {
            return
        }
        downloadAndSaveImage(from: imageURL)
    }
}

extension ImagePageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receivedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = receivedImages[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCell.identifier, for: indexPath) as? ImageGridCell, let imageURL = URL(string: image.largeImageURL) else { return UICollectionViewCell() }
        
        cell.setImage(with: imageURL, pageURL: image.pageURL, largeImageURL: image.largeImageURL, showShareButton: false)
        
        return cell
    }
}


extension ImagePageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width)
    }
}

extension ImagePageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < receivedImages.count else {
            return
        }
        
        let selectedImage = receivedImages[indexPath.row]
        if let imageURL = URL(string: selectedImage.largeImageURL) {
            loadLargeImage(withURL: imageURL)
            updatePhotoFormatLabel(imageURL: imageURL)
            selectedImageURL = imageURL
            zoomToSelectedImage(imageURL: imageURL)
        }
    }
}

extension ImagePageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let searchText = textField.text {
            navigateToSearchResultsVC(with: searchText, imageType: chosenImageType)
        }
        return true
    }
}

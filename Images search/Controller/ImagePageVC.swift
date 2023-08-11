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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var photoFormatLabel: UILabel!
    @IBOutlet weak var previewCollectionView: UICollectionView!
    @IBOutlet weak var downloadButton: UIButton!
    
    var largeImageURL: URL?
    var pageURL: URL?
    let imageCacheService = ImageCacheService.shared
    var selectedImageIndex: Int = 0
    var largeImageURLs: [URL] = []
    var selectedImageURL: URL?
    var isImageLoaded = false
    var relatedImagesCollectionView: UICollectionView?
    
    private var estimateWidth = 95.0
    private var cellMarginSize = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        setupButtons()
        updatePhotoFormatLabel()
        setupPreviewCollectionView()
        setupGridView()
        
        searchTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if let url = largeImageURL {
            selectedImageIndex = largeImageURLs.firstIndex(of: url) ?? 0
            loadLargeImage(withURL: url)
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
        previewCollectionView.register(UINib(nibName: "ImageGridCell", bundle: nil), forCellWithReuseIdentifier: "ImageGridCell")
    }
    
    override func setupGridView() {
        let flow = previewCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        let width = self.calculateWith()
        flow.estimatedItemSize = CGSize(width: width, height: width)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageZoomViewSegue" {
            if let destinationVC = segue.destination as? ImageZoomVC, let imageURL = sender as? URL {
                destinationVC.largeImageURL = imageURL
                destinationVC.selectedImageURL = selectedImageURL
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
    
    func loadLargeImage(withURL url: URL) {
        selectedImageURL = url
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        imageCacheService.loadImage(url: url) { [weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.selectedImage.image = image
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    self?.isImageLoaded = true
                }
            } else {
                print("Failed to load image from URL: \(url)")
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.isImageLoaded = false
            }
        }
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

    @IBAction func zoomButtonTapped(_ sender: Any) {
        guard isImageLoaded, let imageURL = selectedImageURL else {
            return
        }
        performSegue(withIdentifier: "showImageZoomViewSegue", sender: imageURL)
    }
        
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let imageURL = selectedImageURL else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [imageURL], applicationActivities: nil)
        if let presenter = UIApplication.shared.windows.first?.rootViewController {
            presenter.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        guard let imageURL = selectedImageURL else {
            return
        }
        downloadAndSaveImage(from: imageURL)
    }
    
    @IBAction override func filterButtonTapped(_ sender: Any) {
        
        print("Filter button tapped in ImagePageVC")
        let popoverPresenter = PopoverPresenter(button: filterButton, delegate: self, storyboard: storyboard!)
        popoverPresenter.presentPopover()
        
        if let chosenImageType = chosenImageType {
            print("Chosen image type: \(chosenImageType)")
            didChooseImageType(type: chosenImageType)
            
            if let searchText = searchTF.text {
                print("Search text: \(searchText)")
                navigateToSearchResultsVC(with: searchText, imageType: chosenImageType)
            }
        }
    }
    
    func navigateToSearchResultsVC(with searchText: String, imageType: String?) {
        print("Navigating to SearchResultsVC with search text: \(searchText), image type: \(imageType ?? "all")")
        
        if let searchResultsVC = storyboard?.instantiateViewController(withIdentifier: "SearchResultsVC") as? SearchResultsVC {
            searchResultsVC.searchQuery = searchText
            searchResultsVC.imageType = imageType
            searchResultsVC.searchText = searchText
            navigationController?.pushViewController(searchResultsVC, animated: true)
        }
    }
}

extension ImagePageVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receivedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGridCell", for: indexPath) as? ImageGridCell
        
        let image = receivedImages[indexPath.row]
        guard let imageURL = URL(string: image.largeImageURL) else {
            return cell ?? UICollectionViewCell()
        }
        cell?.setImage(with: imageURL, pageURL: image.pageURL, largeImageURL: image.largeImageURL, showShareButton: false)

        return cell ?? UICollectionViewCell()
    }
}

extension ImagePageVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width)
    }
    
    func calculateWith() -> CGFloat {
        let estimateWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        return width
    }
}

extension ImagePageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < receivedImages.count else {
            return
        }
        
        let selectedImage = receivedImages[indexPath.row]
        if let imageURL = URL(string: selectedImage.largeImageURL) {
            loadLargeImage(withURL: imageURL)
            updatePhotoFormatLabel(imageURL: imageURL)
            selectedImageURL = imageURL
            shareButton.setImageURL(imageURL)
            downloadButton.setImageURL(imageURL)
            zoomToSelectedImage(imageURL: imageURL)
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
}

extension UIButton {
    func setImageURL(_ imageURL: URL) {
    }
}

extension ImagePageVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let searchText = textField.text {
            navigateToSearchResultsVC(with: searchText, imageType: chosenImageType)
        }
        return true
    }
}

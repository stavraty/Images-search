//
//  File.swift
//  Images search
//
//  Created by AS on 23.08.2023.
//

import UIKit
import TOCropViewController
import Photos

class ImageEditViewController: UIViewController, TOCropViewControllerDelegate {
    
    var imageToEdit: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCropViewController()
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        saveCroppedImageToGallery(image)
        
        cropViewController.dismiss(animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        
        cropViewController.dismiss(animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupCropViewController() {
        guard let imageToEdit = imageToEdit else {
            return
        }
        
        let cropViewController = TOCropViewController(image: imageToEdit)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    private func saveCroppedImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            if success {
                self?.showAlert(title: "Success", message: "Image saved to the gallery.")
            } else {
                self?.showAlert(title: "Error", message: "Failed to save the image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}



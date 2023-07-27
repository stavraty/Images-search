//
//  ImageZoomVC.swift
//  Images search
//
//  Created by AS on 24.07.2023.
//

import UIKit

class ImageZoomVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var largeImageURL: URL?
    private let imageCacheService = ImageCacheService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        loadImage()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
    }
    
    private func updateScrollViewContentSize() {
        if let image = imageView.image {
            scrollView.contentSize = image.size
        }
    }
    
    private func loadImage() {
        guard let imageURL = largeImageURL else {
            return
        }
        
        imageCacheService.loadImage(url: imageURL) { [weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.updateScrollViewContentSize()
                }
            } else {
                print("Failed to load image from URL: \(imageURL)")
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if let imagePageVC = navigationController?.viewControllers.first(where: { $0 is ImagePageVC }) {
            navigationController?.popToViewController(imagePageVC, animated: true)
        }
    }
}

extension ImageZoomVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > imageView.frame.height
                
                let top = 0.5 * (conditioTop ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}

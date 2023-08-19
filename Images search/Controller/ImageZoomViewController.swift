//
//  ImageZoomVC.swift
//  Images search
//
//  Created by AS on 24.07.2023.
//

import UIKit

class ImageZoomViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    var largeImageURL: URL?
    var selectedImageURL: URL?
    private let imageCacheService = ImageCacheService.shared
    private let minimumZoomScale: CGFloat = 1.0
    private let maximumZoomScale: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        loadImage()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
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
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if let imagePageVC = navigationController?.viewControllers.first(where: { $0 is ImagePageViewController }) {
            navigationController?.popToViewController(imagePageVC, animated: true)
        }
    }
}

extension ImageZoomViewController: UIScrollViewDelegate {
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

//
//  SearchResultsVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

class SearchResultsViewController: BaseViewController {
    
    private var estimateWidth = 140.0
    private var cellMarginSize = 16.0
    private var pageURL: URL?
    private let imagePageViewControllerIdentifier = "ImagePageViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        registerCells()
        setupGridView()
        fetchImages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    override func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        let width = self.calculateWith()
        flow.estimatedItemSize = CGSize(width: width, height: width)
    }
    
    func registerCells() {
        collectionView?.register(UINib(nibName: ImageGridCell.nibName, bundle: nil), forCellWithReuseIdentifier: ImageGridCell.identifier)
        filterCollectionView?.register(UINib(nibName: FilterCell.nibName, bundle: nil), forCellWithReuseIdentifier: FilterCell.identifier)
    }
    
    private func setupDelegates() {
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.filterCollectionView?.dataSource = self
        self.filterCollectionView?.delegate = self
        searchTF.delegate = self
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return images.count
        } else if collectionView == self.filterCollectionView {
            return filters.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCell.identifier, for: indexPath) as? ImageGridCell
            let image = images[indexPath.row]
            guard let imageURL = URL(string: image.webformatURL) else {
                return UICollectionViewCell()
            }
            cell?.setImage(with: imageURL, pageURL: image.pageURL, largeImageURL: image.largeImageURL, showShareButton: true)
            
            return cell ?? UICollectionViewCell()
        } else if collectionView == self.filterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell
            let filter = filters[indexPath.row]
            cell?.setUp(with: filter, isSelected: indexPath.row == selectedFilterIndex)
            return cell ?? UICollectionViewCell()
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView && indexPath.row == images.count - 1 {
            fetchNextPage()
        }
    }
}

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
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

extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.filterCollectionView {
            if indexPath.row != 0 {
                selectedTag = filters[indexPath.row]
                
                filters = filters.filter { $0 != selectedTag }
                filters.insert(selectedTag ?? defaultSelectedFilter, at: 0)
                
                collectionView.reloadData()
                self.images = []
                self.currentPage = 1
                self.searchQuery = selectedTag
                fetchImages()
            }
        } else if collectionView == self.collectionView {
            let selectedImageURL = URL(string: images[indexPath.row].largeImageURL)
            let selectedPageURL = images[indexPath.row].pageURL
            openImagePageVC(with: selectedImageURL)
        }
    }
    
    func openImagePageVC(with imageURL: URL?) {
        guard let imageURL = imageURL else { return }
        
        if let imagePageVC = storyboard?.instantiateViewController(withIdentifier: imagePageViewControllerIdentifier) as? ImagePageViewController {
            imagePageVC.largeImageURL = imageURL
            imagePageVC.pageURL = pageURL
            imagePageVC.relatedImagesCollectionView = self.collectionView
            imagePageVC.receivedImages = images
            imagePageVC.searchText = searchTF.text
            self.navigationController?.pushViewController(imagePageVC, animated: true)
        }
    }
}

extension SearchResultsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchQuery = textField.text
        images = []
        currentPage = 1
        fetchImages()
        return true
    }
}

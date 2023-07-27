//
//  SearchResultsVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

class SearchResultsVC: BaseVC {
    
    private var estimateWidth = 160.0
    private var cellMarginSize = 16.0
    
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
            self.collectionView.reloadData()
        }
    }

    private func setupDelegates() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.filterCollectionView.dataSource = self
        self.filterCollectionView.delegate = self
        searchTF.delegate = self
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: "ImageGridCell", bundle: nil), forCellWithReuseIdentifier: "ImageGridCell")
        filterCollectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
    }
    
    override func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        let width = self.calculateWith()
        flow.estimatedItemSize = CGSize(width: width, height: width)
    }
    
    override func fetchImages() {
        self.query = searchQuery ?? ""
        self.imageType = imageType ?? "all"
        self.filters.removeAll()
        self.filters.append(selectedTag ?? "Related")
        fetchNextPage()
    }

    override func fetchNextPage() {
        guard let query = query, let imageType = imageType else {
            return
        }

        api.fetchImages(query: query, imageType: imageType, page: currentPage) { [weak self] result in
            switch result {
            case .success(let pixabayResponse):
                self?.images.append(contentsOf: pixabayResponse.hits)

                var tempTags = [String]()
                for image in pixabayResponse.hits {
                    let tags = image.tags.split(separator: ",")
                    tempTags.append(contentsOf: tags.map { String($0) })
                }

                let uniqueTags = Array(Set(tempTags)).prefix(50).sorted()
                self?.filters.append(contentsOf: uniqueTags.filter { $0 != self?.selectedTag })

                self?.currentPage += 1
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.filterCollectionView.reloadData()
                    self?.setupGridView()

                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    let formattedTotal = numberFormatter.string(from: NSNumber(value: pixabayResponse.total)) ?? "0"

                    self?.totalImagesCountLabel.text = "\(formattedTotal) Free Images"
                    (self?.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SearchResultsVC: UICollectionViewDataSource {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGridCell", for: indexPath) as? ImageGridCell
            let image = images[indexPath.row]
            guard let imageURL = URL(string: image.webformatURL) else {
                return UICollectionViewCell()
            }
            cell?.setImage(with: imageURL, pageURL: image.pageURL, largeImageURL: image.largeImageURL)
            return cell ?? UICollectionViewCell()
        } else if collectionView == self.filterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell
            let filter = filters[indexPath.row]
            cell?.configure(with: filter, isSelected: indexPath.row == selectedFilterIndex)
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

extension SearchResultsVC: UICollectionViewDelegateFlowLayout {
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

extension SearchResultsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.filterCollectionView {
            if indexPath.row != 0 {
                selectedTag = filters[indexPath.row]
                
                filters = filters.filter { $0 != selectedTag }
                filters.insert(selectedTag ?? "Related", at: 0)
                
                collectionView.reloadData()
                self.images = []
                self.currentPage = 1
                self.searchQuery = selectedTag
                fetchImages()
            }
        } else if collectionView == self.collectionView {
            let selectedImageURL = URL(string: images[indexPath.row].largeImageURL)
            openImagePageVC(with: selectedImageURL)
        }
    }
    
    func openImagePageVC(with imageURL: URL?) {
        guard let imageURL = imageURL else { return }

        if let imagePageVC = storyboard?.instantiateViewController(withIdentifier: "ImagePageVC") as? ImagePageVC {
            imagePageVC.largeImageURL = imageURL
            self.navigationController?.pushViewController(imagePageVC, animated: true)
        }
    }
}

extension SearchResultsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchQuery = textField.text
        images = []
        currentPage = 1
        fetchImages()
        return true
    }
}

//
//  SearchResultsVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

class SearchResultsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    
    private let api = APIService()
    private var images: [PixabayResponse.Image] = []
    private var currentPage = 1
    private var query: String?
    private var imageType: String?
    private var estimateWidth = 160.0
    private var cellMarginSize = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        registerCells()
        self.setupGridView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: "ImageGridCell", bundle: nil), forCellWithReuseIdentifier: "ImageGridCell")
        filterCollectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")

    }
    
    func fetchImages(query: String, imageType: String) {
        self.query = query
        self.imageType = imageType
        fetchNextPage()
    }
    
    func fetchNextPage() {
        guard let query = query, let imageType = imageType else {
            return
        }
        
        api.fetchImages(query: query, imageType: imageType, page: currentPage) { [weak self] result in
            switch result {
            case .success(let pixabayResponse):
                self?.images.append(contentsOf: pixabayResponse.hits)
                self?.currentPage += 1
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.setupGridView()
                    (self?.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        let width = self.calculateWith()
        flow.estimatedItemSize = CGSize(width: width, height: width)
    }

    @IBAction func goHomeButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
    }
}

extension SearchResultsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGridCell", for: indexPath) as? ImageGridCell
        guard let imageURL = URL(string: images[indexPath.row].webformatURL) else {
            return UICollectionViewCell()
        }
        cell?.setImage(with: imageURL)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == images.count - 1 {
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

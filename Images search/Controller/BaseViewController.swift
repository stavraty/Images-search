//
//  BaseVC.swift
//  Images search
//
//  Created by AS on 21.07.2023.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var secondSearchContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var totalImagesCountLabel: UILabel?
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var filterCollectionView: UICollectionView?
    
    private let api = APIService()
    private let searchResultsViewControllerIdentifier = "SearchResultsViewController"
    private let imageTypeMap: [String: String] = ["all": "Images", "photo": "Photo", "illustration": "Illustration", "vector": "Vector"]
    private var query: String?
    private var selectedFilter: String = "Related"
    private var previews: [URL] = []
    private let defaultCornerRadius: CGFloat = 5
    private let defaultBorderWidth: CGFloat = 1.0
    private let defaultBorderColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00).cgColor
    private let defaultBorderColorGray = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
    private let defaultImageType = "all"
    private let maxTagsToShow = 50
    let defaultSelectedFilter = "Related"
    
    var images: [PixabayResponse.Image] = []
    var chosenImageType: String?
    var currentPage = 1
    var imageType: String?
    var searchText: String?
    var searchQuery: String?
    var selectedFilterIndex: Int = 0
    var selectedTag: String?
    var filters: [String] = []
    var receivedImages: [PixabayResponse.Image] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchTFAppearance()
        setupTapGesture()
        setupButtons()
        setupSearchView()
        setupHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func fetchImages() {
        self.query = searchQuery ?? ""
        self.imageType = imageType ?? defaultImageType
        self.filters.removeAll()
        self.filters.append(selectedTag ?? defaultSelectedFilter)
        self.previews.removeAll()
        fetchNextPage()
    }
    
    func fetchNextPage() {
        guard let query = query, let imageType = imageType else {
            return
        }
        
        api.fetchImages(query: query, imageType: imageType, page: currentPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let pixabayResponse):
                self.images.append(contentsOf: pixabayResponse.hits)
                
                var tempTags = [String]()
                for image in pixabayResponse.hits {
                    let tags = image.tags.split(separator: ",")
                    tempTags.append(contentsOf: tags.map { String($0) })
                }
                
                for image in pixabayResponse.hits {
                    if let previewURL = URL(string: image.previewURL) {
                        self.previews.append(previewURL)
                    }
                }
                
                let uniqueTags = Array(Set(tempTags)).prefix(self.maxTagsToShow).sorted()
                self.filters.append(contentsOf: uniqueTags.filter { $0 != self.selectedTag })
                
                self.currentPage += 1
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    self.filterCollectionView?.reloadData()
                    self.setupGridView()
                    
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    let formattedTotal = numberFormatter.string(from: NSNumber(value: pixabayResponse.total)) ?? "0"
                    
                    self.totalImagesCountLabel?.text = "\(formattedTotal) Free Images"
                    (self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
                }
            case .failure(let error): break
            }
        }
    }
    
    func setupGridView() {
        fatalError("setupGridView() method must be overridden in subclasses.")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupSearchTFAppearance() {
        searchTF.returnKeyType = .search
        searchTF.text = searchText
    }
    
    private func setupButtons() {
        setupGoHomeButton()
        setupFilterButton()
    }
    
    private func setupGoHomeButton() {
        homeButton.setTitle("", for: .normal)
        homeButton.layer.cornerRadius = defaultCornerRadius
        homeButton.clipsToBounds = true
    }
    
    private func setupFilterButton() {
        filterButton.setTitle("", for: .normal)
        filterButton.layer.cornerRadius = defaultCornerRadius
        filterButton.clipsToBounds = true
        filterButton.layer.borderWidth = defaultBorderWidth
        filterButton.layer.borderColor = defaultBorderColor
    }
    
    private func setupSearchView() {
        secondSearchContainerView.layer.cornerRadius = defaultCornerRadius
        secondSearchContainerView.clipsToBounds = true
        secondSearchContainerView.layer.borderWidth = defaultBorderWidth
        secondSearchContainerView.layer.borderColor = defaultBorderColor
    }
    
    private func setupHeaderView() {
        headerView.layer.borderWidth = defaultBorderWidth
        headerView.layer.borderColor = defaultBorderColor
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func goHomeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        if self is SearchResultsViewController {
            let popoverPresenter = PopoverPresenter(button: filterButton, delegate: self, storyboard: storyboard!)
            popoverPresenter.presentPopover()
        } else {
            navigateToSearchResultsViewController()
        }
    }
}

extension BaseViewController: SelectImageTypeTableVCDelegate {
    func didChooseImageType(type: String) {
        self.chosenImageType = type
        self.images = []
        self.currentPage = 1
        self.imageType = self.chosenImageType ?? defaultImageType
        self.fetchImages()
    }
    
    func displayStringForType(type: String) -> String? {
        return imageTypeMap[type]
    }
    
    func navigateToSearchResultsViewController() {
        if let searchResultsVC = storyboard?.instantiateViewController(withIdentifier: searchResultsViewControllerIdentifier) as? SearchResultsViewController {
            navigationController?.pushViewController(searchResultsVC, animated: true)
        }
    }
}

extension BaseViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

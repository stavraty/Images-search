//
//  BaseVC.swift
//  Images search
//
//  Created by AS on 21.07.2023.
//

import UIKit

class BaseVC: UIViewController {
    
    @IBOutlet weak var goHomeButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var secondSearchContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var totalImagesCountLabel: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    let api = APIService()
    var images: [PixabayResponse.Image] = []
    var chosenImageType: String?
    var currentPage = 1
    var imageType: String?
    var query: String?
    var searchText: String?
    var searchQuery: String?
    var selectedFilterIndex: Int = 0
    var selectedFilter: String = "Related"
    var selectedTag: String?
    var filters: [String] = []
    var receivedImages: [PixabayResponse.Image] = []
    
    var previews: [URL] = []
    
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
    
    private func setupSearchTFAppearance() {
        searchTF.returnKeyType = .search
        searchTF.text = searchText
    }
    
    private func setupButtons() {
        setupGoHomeButton()
        setupFilterButton()
    }
    
    private func setupGoHomeButton() {
        goHomeButton.setTitle("", for: .normal)
        goHomeButton.layer.cornerRadius = 5
        goHomeButton.clipsToBounds = true
    }
    
    private func setupFilterButton() {
        filterButton.setTitle("", for: .normal)
        filterButton.layer.cornerRadius = 5
        filterButton.clipsToBounds = true
        filterButton.layer.borderWidth = 1.0
        filterButton.layer.borderColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00).cgColor
    }
    
    private func setupSearchView() {
        secondSearchContainerView.layer.cornerRadius = 5
        secondSearchContainerView.clipsToBounds = true
        secondSearchContainerView.layer.borderWidth = 1.0
        secondSearchContainerView.layer.borderColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00).cgColor
    }
    
    private func setupHeaderView() {
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupGridView() {
        fatalError("setupGridView() method must be overridden in subclasses.")
    }
    
    func fetchImages() {
        self.query = searchQuery ?? ""
        self.imageType = imageType ?? "all"
        self.filters.removeAll()
        self.filters.append(selectedTag ?? "Related")
        self.previews.removeAll()
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

                var tempTags = [String]()
                for image in pixabayResponse.hits {
                    let tags = image.tags.split(separator: ",")
                    tempTags.append(contentsOf: tags.map { String($0) })
                }

                for image in pixabayResponse.hits {
                    if let previewURL = URL(string: image.previewURL) {
                        self?.previews.append(previewURL)
                    }
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func goHomeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        let popoverPresenter = PopoverPresenter(button: filterButton, delegate: self, storyboard: storyboard!)
        popoverPresenter.presentPopover()
    }
}

extension BaseVC: SelectImageTypeTableVCDelegate {
    func didChooseImageType(type: String) {
        self.chosenImageType = type
        self.images = []
        self.currentPage = 1
        self.imageType = self.chosenImageType ?? "all"
        self.fetchImages()
    }

    func displayStringForType(type: String) -> String? {
        let imageTypeMap: [String: String] = ["all": "Images", "photo": "Photo", "illustration": "Illustration", "vector": "Vector"]
        return imageTypeMap[type]
    }
}

extension BaseVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

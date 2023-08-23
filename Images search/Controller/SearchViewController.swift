//
//  ViewController.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

protocol ImageSelectionDelegate: AnyObject {
    func didSelectImage(_ image: UIImage?)
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var selectImageTypeButton: UIButton!
    @IBOutlet weak var searchContainerView: UIView!
    
    private var chosenImageType: String? = nil
    private let api = APIService()
    private var currentPage = 1
    private var query: String = ""
    private var imageType: String = "all"
    private let imageTypeMap: [String: String] = ["all": "Images", "photo": "Photo", "illustration": "Illustration", "vector": "Vector"]
    private let popoverSegueIdentifier = "showSearchResults"
    private let imagePageSegueIdentifier = "ImagePageSegue"
    private let borderHeight: CGFloat = 24
    private let defaultCornerRadius: CGFloat = 5
    private let defaultBorderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
    
    weak var delegate: ImageSelectionDelegate?
    var selectedImageFromGallery: URL? //UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestures()
        setupButtonBorder()
        setupTapGesture()
        setupSearchTextField()
        setupSearchView()
        initializeConstants()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == popoverSegueIdentifier, let destinationVC = segue.destination as? SearchResultsViewController {
            destinationVC.searchQuery = searchTF.text
            destinationVC.imageType = chosenImageType
            destinationVC.searchText = searchTF.text
        }
        
        if segue.identifier == imagePageSegueIdentifier, let destinationVC = segue.destination as? ImagePageViewController {
            if let imageURL = selectedImageFromGallery {
                destinationVC.largeImageURL = imageURL
            }
        }
    }
    
    @objc private func tapped() {
        let popoverPresenter = PopoverPresenter(button: selectImageTypeButton, delegate: self, storyboard: storyboard!)
        popoverPresenter.presentPopover()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func initializeConstants() {
        query = searchTF.text ?? ""
        imageType = chosenImageType ?? "all"
    }
    
    private func setupButtonBorder() {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = defaultBorderColor
        let verticalInset: CGFloat = (selectImageTypeButton.frame.height - borderHeight) / 2
        borderLayer.frame = CGRect(x: 0, y: verticalInset, width: 1, height: borderHeight)
        selectImageTypeButton.layer.addSublayer(borderLayer)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchTextField() {
        searchTF.delegate = self
        searchTF.returnKeyType = .search
    }
    
    private func setupSearchView() {
        searchContainerView.layer.cornerRadius = defaultCornerRadius
        searchContainerView.clipsToBounds = true
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.numberOfTapsRequired = 1
        selectImageTypeButton.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        api.fetchImages(query: query, imageType: imageType, page: currentPage) {_ in
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: self?.popoverSegueIdentifier ?? "", sender: self)
            }
        }
    }
    
    @IBAction func selectFromGalleryButtonTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension SearchViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension SearchViewController: SelectImageTypeTableVCDelegate {
    func didChooseImageType(type: String) {
        
        chosenImageType = type
        selectImageTypeButton.setTitle(displayStringForType(type: type), for: .normal)
    }
    
    func displayStringForType(type: String) -> String? {
        return imageTypeMap[type]
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButtonTapped(textField)
        return true
    }
}

extension SearchViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            selectedImageFromGallery = imageURL
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.performSegue(withIdentifier: "ImagePageSegue", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

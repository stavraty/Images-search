//
//  ViewController.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

class SearchVC: UIViewController {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var selectImageTypeButton: UIButton!
    @IBOutlet weak var searchContainerView: UIView!
    
    var chosenImageType: String? = nil
    let api = APIService()
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestures()
        setupButtonBorder()
        setupTapGesture()
        setupSearchTextField()
        setupSearchView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchResults", let destinationVC = segue.destination as? SearchResultsVC {
            destinationVC.searchQuery = searchTF.text
            destinationVC.imageType = chosenImageType
            destinationVC.searchText = searchTF.text
        }
    }
    
    func setupButtonBorder() {
        let borderLayer = CALayer()
        
        borderLayer.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        
        let height: CGFloat = 24
        let verticalInset: CGFloat = (selectImageTypeButton.frame.height - height) / 2
        borderLayer.frame = CGRect(x: 0, y: verticalInset, width: 1, height: height)
        selectImageTypeButton.layer.addSublayer(borderLayer)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupSearchTextField() {
        searchTF.delegate = self
        searchTF.returnKeyType = .search
    }
    
    func setupSearchView() {
        searchContainerView.layer.cornerRadius = 5
        searchContainerView.clipsToBounds = true
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.numberOfTapsRequired = 1
        selectImageTypeButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapped() {
        let popoverPresenter = PopoverPresenter(button: selectImageTypeButton, delegate: self, storyboard: storyboard!)
        popoverPresenter.presentPopover()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let query = searchTF.text ?? ""
        let imageType = chosenImageType ?? "all"
        api.fetchImages(query: query, imageType: imageType, page: currentPage) {_ in
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "showSearchResults", sender: self)
            }
        }
    }
}

extension SearchVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension SearchVC: SelectImageTypeTableVCDelegate {
    func didChooseImageType(type: String) {
        
        chosenImageType = type
        selectImageTypeButton.setTitle(displayStringForType(type: type), for: .normal)
    }

    func displayStringForType(type: String) -> String? {
        let imageTypeMap: [String: String] = ["all": "Images", "photo": "Photo", "illustration": "Illustration", "vector": "Vector"]
        return imageTypeMap[type]
    }
}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButtonTapped(textField)
        return true
    }
}

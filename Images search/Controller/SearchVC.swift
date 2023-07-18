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
    
    var chosenImageType: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestures()
        setupButtonBorder()
        setupTapGesture()
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
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.numberOfTapsRequired = 1
        selectImageTypeButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapped() {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? SelectImageTypeTableVC else { return }
        
        popVC.modalPresentationStyle = .popover
        popVC.delegate = self

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.selectImageTypeButton
        popOverVC?.sourceRect = CGRect(x: self.selectImageTypeButton.bounds.midX, y: self.selectImageTypeButton.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 250, height: 250)
        
        self.present(popVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let searchResultsVC = storyboard.instantiateViewController(withIdentifier: "SearchResultsVC") as? SearchResultsVC {
            let query = searchTF.text ?? ""
            let imageType = chosenImageType ?? "all"
            searchResultsVC.fetchImages(query: query, imageType: imageType)
            navigationController?.pushViewController(searchResultsVC, animated: true)
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

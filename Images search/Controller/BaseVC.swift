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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTapGesture()
        setupButtons()
        setupSearchView()
        setupHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func goHomeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true) //popToRootViewController(animated: true)
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        let popoverPresenter = PopoverPresenter(button: filterButton, delegate: self, storyboard: storyboard!)
        popoverPresenter.presentPopover()
    }
}

extension BaseVC: SelectImageTypeTableVCDelegate {
    func didChooseImageType(type: String) {
//        self.chosenImageType = type
//        self.images = []
//        self.currentPage = 1
//        self.imageType = self.chosenImageType ?? "all"
//        self.fetchImages()
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

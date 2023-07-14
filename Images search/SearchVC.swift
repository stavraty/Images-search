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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestures()
        setupButtonBorder()
        
    }
    
    func setupButtonBorder() {
        let borderLayer = CALayer()
        
        borderLayer.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor

        let height: CGFloat = 24
        let verticalInset: CGFloat = (selectImageTypeButton.frame.height - height) / 2
        borderLayer.frame = CGRect(x: 0, y: verticalInset, width: 1, height: height)
        selectImageTypeButton.layer.addSublayer(borderLayer)
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
}

extension SearchVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension SearchVC: SelectImageTypeTableVCDelegate {
    func didChooseImageType(type: String) {
        selectImageTypeButton.setTitle(type, for: .normal)
    }
}

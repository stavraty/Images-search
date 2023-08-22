//
//  PopoverPresenter.swift
//  Images search
//
//  Created by AS on 19.07.2023.
//

import UIKit

class PopoverPresenter {
    
    let button: UIButton
    let delegate: SelectImageTypeTableVCDelegate
    let storyboard: UIStoryboard
    static let popoverStoryboardID = "popVC"
    
    init(button: UIButton, delegate: SelectImageTypeTableVCDelegate, storyboard: UIStoryboard) {
        self.button = button
        self.delegate = delegate
        self.storyboard = storyboard
    }
    
    func presentPopover() {
        guard let popVC = storyboard.instantiateViewController(withIdentifier: PopoverPresenter.popoverStoryboardID) as? SelectImageTypeTableViewController else { return }
        
        popVC.modalPresentationStyle = .popover
        popVC.delegate = delegate

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = delegate as? UIPopoverPresentationControllerDelegate
        popOverVC?.sourceView = button
        popOverVC?.sourceRect = CGRect(x: button.bounds.midX, y: button.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 250, height: 250)
        
        if let delegate = delegate as? UIViewController {
            delegate.present(popVC, animated: true)
        }
    }
}

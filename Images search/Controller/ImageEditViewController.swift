//
//  File.swift
//  Images search
//
//  Created by AS on 23.08.2023.
//

import UIKit
import TOCropViewController
import Photos

class ImageEditViewController: UIViewController {
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var secondSearchContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    // var imageToEdit: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cropContainerVC = storyboard?.instantiateViewController(withIdentifier: "CropContainerView") as? CropContainerViewController {
            addChild(cropContainerVC)
            cropContainerVC.view.frame = containerView.bounds
            containerView.addSubview(cropContainerVC.view)
            cropContainerVC.didMove(toParent: self)
        }
    }
}

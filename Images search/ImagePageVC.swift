//
//  ImagePageVC.swift
//  Images search
//
//  Created by AS on 12.07.2023.
//

import UIKit

class ImagePageVC: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}

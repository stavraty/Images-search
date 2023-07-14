//
//  TableViewController.swift
//  Images search
//
//  Created by AS on 14.07.2023.
//

import UIKit

protocol SelectImageTypeTableVCDelegate: AnyObject {
    func didChooseImageType(type: String)
}

class SelectImageTypeTableVC: UITableViewController {
    
    weak var delegate: SelectImageTypeTableVCDelegate?
    
    let imageTypesArray = ["Images",
                           "Photos",
                           "Illustrations",
                           "Vectors"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isScrollEnabled = false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didChooseImageType(type: imageTypesArray[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 200, height: tableView.contentSize.height)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageTypesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTypeCell", for: indexPath)

        let textData = imageTypesArray[indexPath.row]
        cell.textLabel?.text = textData

        return cell
    }
}

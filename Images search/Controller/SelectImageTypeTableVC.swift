//
//  TableViewController.swift
//  Images search
//
//  Created by AS on 14.07.2023.
//

import UIKit

protocol SelectImageTypeTableVCDelegate: AnyObject {
    func didChooseImageType(type: String)
    func displayStringForType(type: String) -> String?
}

class SelectImageTypeTableVC: UITableViewController {
    
    weak var delegate: SelectImageTypeTableVCDelegate?
    
    let imageTypesAPI = ["all", "photo", "illustration", "vector"]
    let imageTypesDisplay = ["Images", "Photo", "Illustration", "Vector"]
    let imageTypeMap: [String: String] = ["Images": "all", "Photo": "photo", "Illustration": "illustration", "Vector": "vector"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isScrollEnabled = false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAPIType = imageTypesAPI[indexPath.row]
        delegate?.didChooseImageType(type: selectedAPIType)
        dismiss(animated: true, completion: nil)
    }

    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 200, height: tableView.contentSize.height)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageTypesAPI.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTypeCell", for: indexPath)

        let textData = imageTypesDisplay[indexPath.row]
        cell.textLabel?.text = textData

        return cell
    }
}

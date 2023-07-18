//
//  FilterCell.swift
//  Images search
//
//  Created by AS on 18.07.2023.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var filterLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with filter: String) {
        filterLabel.text = filter
    }
}


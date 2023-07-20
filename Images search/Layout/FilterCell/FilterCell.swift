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
    }
    func configure(with text: String, isSelected: Bool) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        filterLabel.text = trimmedText.capitalizingFirstLetter()

        if isSelected {
            filterLabel.textColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.00)
            self.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        } else {
            filterLabel.textColor = .black
            self.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00)
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).localizedCapitalized + dropFirst()
    }
}


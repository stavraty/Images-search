//
//  FilterCell.swift
//  Images search
//
//  Created by AS on 18.07.2023.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    @IBOutlet weak var filterLabel: UILabel!
    
    static let identifier = "FilterCell"
    static let nibName = "FilterCell"
    
    private let selectedTextColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.00)
    private let selectedBackgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
    private let defaultTextColor = UIColor.black
    private let defaultBackgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.00)
    private let cornerRadius: CGFloat = 5.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUp(with text: String, isSelected: Bool) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        filterLabel.text = trimmedText.capitalizingFirstLetter()
        
        if isSelected {
            filterLabel.textColor = selectedTextColor
            self.backgroundColor = selectedBackgroundColor
        } else {
            filterLabel.textColor = defaultTextColor
            self.backgroundColor = defaultBackgroundColor
        }
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).localizedCapitalized + dropFirst()
    }
}


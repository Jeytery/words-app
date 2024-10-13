//
//  DoubleTitleTableViewCell.swift
//  WordsApp
//
//  Created by Jeytery on 22.10.2022.
//

import Foundation
import UIKit

class DoubleTitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

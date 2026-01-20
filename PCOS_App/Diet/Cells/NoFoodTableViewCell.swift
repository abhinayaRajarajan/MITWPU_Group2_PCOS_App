//
//  NoFoodTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class NoFoodTableViewCell: UITableViewCell {
    static var identifier = "NoFoodTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  MuscleTypeSelectionTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class MuscleTypeSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var muscleTypeLabel: UILabel!
    @IBOutlet weak var muscleTypeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

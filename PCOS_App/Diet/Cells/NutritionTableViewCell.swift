//
//  NutritionTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class NutritionTableViewCell: UITableViewCell {

    @IBOutlet weak var carbsGram: UILabel!
    @IBOutlet weak var fatsGram: UILabel!
    @IBOutlet weak var proteinGram: UILabel!
    @IBOutlet weak var fatsProgress: UIProgressView!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var proteinProgress: UIProgressView!
    @IBOutlet weak var caloriesConsumed: UILabel!
    @IBOutlet weak var completionCircle: UIImageView!
    
    static let identifier = "NutritionTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "NutritionTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

        
}

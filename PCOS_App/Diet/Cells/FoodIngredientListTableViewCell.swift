//
//  FoodIngredientListTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//

import UIKit

class FoodIngredientListTableViewCell: UITableViewCell {

    @IBOutlet weak var IngredientNameLabel: UILabel!
    @IBOutlet weak var IngredientCalorieLabel: UILabel!
    
    @IBOutlet weak var IngredientWeightLabel: UILabel!
    
    static var identifier = "FoodIngredientListTableViewCell"
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
    
    func configureCell(with ingredient: Ingredient){
        IngredientNameLabel.text = ingredient.name
        IngredientCalorieLabel.text = "\(ingredient.calories) kcal"
        IngredientWeightLabel.text = "\((ingredient.weight) ?? 100) g"
    }
    
}

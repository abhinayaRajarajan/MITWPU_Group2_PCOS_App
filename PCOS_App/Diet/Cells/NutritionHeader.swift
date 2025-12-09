//
//  NutritionHeader.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class NutritionHeader: UIView {

    @IBOutlet weak var nutritionCard: UIView!
    @IBOutlet weak var recommendationCard: UIView!
    
    @IBOutlet weak var stackMacros: UIStackView!
    @IBOutlet weak var progressCircle: UIImageView!
    @IBOutlet weak var fatsProgress: UIProgressView!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var proteinProgress: UIProgressView!
    
    @IBOutlet weak var calToBeConsumed: UILabel!
    @IBOutlet weak var caloriesConsumed: UILabel!
    
    @IBOutlet weak var fatsGm: UILabel!
    @IBOutlet weak var carbsGm: UIView!
    @IBOutlet weak var proteinGm: UILabel!
    
    func configure(){
        nutritionCard.layer.cornerRadius = 25
        recommendationCard.layer.cornerRadius = 15
        
        nutritionCard.layer.borderWidth = 1
        nutritionCard.layer.borderColor = UIColor.systemGray4.cgColor
        
        recommendationCard.layer.shadowColor = UIColor.black.cgColor
        recommendationCard.layer.shadowOpacity = 0.2
        
        stackMacros.layer.cornerRadius = 25
        stackMacros.layer.backgroundColor = UIColor.systemGray6.cgColor
        
        caloriesConsumed.text = "561"
        
    }
}

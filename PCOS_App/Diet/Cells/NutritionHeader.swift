//
//  NutritionHeader.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class NutritionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var nutritionCard: UIView!
    
    
    @IBOutlet weak var stackMacros: UIStackView!
    
    @IBOutlet weak var progressCircle: CompletionCircleView!
    
    @IBOutlet weak var fatsProgress: UIProgressView!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var proteinProgress: UIProgressView!
    
    @IBOutlet weak var calToBeConsumed: UILabel!
    @IBOutlet weak var caloriesConsumed: UILabel!
    
    @IBOutlet weak var fatsGm: UILabel!
    @IBOutlet weak var carbsGm: UILabel!
    @IBOutlet weak var proteinGm: UILabel!
    
    var calories : Double = 0
    var fats : Double = 0
    var protein : Double = 0
    var carbs : Double = 0
    var fibre: Double = 0
    
    static var identifier = "NutritionHeader"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    func configure(){
        nutritionCard.layer.cornerRadius = 16
        nutritionCard.layer.masksToBounds = true
        stackMacros.layer.cornerRadius = 16
    }
    
    func setValues(){
        for food in FoodLogDataSource.filteredFoods(){
            calories += food.calories
            fats += food.fatsContent
            protein += food.proteinContent
            carbs += food.carbsContent
        }
        calToBeConsumed.text = "/2000"
        caloriesConsumed.text = "\(Int(calories))"
        fatsGm.text = "\(Int(fats))"
        proteinGm.text = "\(Int(protein))"
        carbsGm.text = "\(Int(carbs))"
        
        fatsProgress.progress = Float(fats/60)
        carbsProgress.progress = Float(carbs/180)
        proteinProgress.progress = Float(protein/90)
        
        progressCircle.setProgress(to: Float(calories)/2000)
    }
    
    func updateValues(_ food: Food){
        calories += food.calories
        fats += food.fatsContent
        protein += food.proteinContent
        carbs += food.carbsContent
        
        caloriesConsumed.text = "\(Int(calories))"
        fatsGm.text = "\(Int(fats))"
        proteinGm.text = "\(Int(protein))"
        carbsGm.text = "\(Int(carbs))"
        
        fatsProgress.progress = Float(fats/60)
        carbsProgress.progress = Float(carbs/180)
        proteinProgress.progress = Float(protein/90)
        
        progressCircle.setProgress(to: Float(calories)/2000)
    }
}

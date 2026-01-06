//
//  NutritionHeader.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class NutritionHeader: UIView {

    @IBOutlet weak var nutritionCard: UIView!
    
    //@IBOutlet weak var recommendationCard: UIView!
    @IBOutlet weak var AIToken: UIView!
    
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
    
    
    func configure(){
        nutritionCard.layer.cornerRadius = 25
        //recommendationCard.layer.cornerRadius = 15
        
        nutritionCard.layer.borderWidth = 1
        nutritionCard.layer.borderColor = UIColor.systemGray4.cgColor
        
//        recommendationCard.layer.shadowColor = UIColor.black.cgColor
//        recommendationCard.layer.shadowOpacity = 0.2
        
        stackMacros.layer.cornerRadius = 25
        //stackMacros.layer.backgroundColor = UIColor.systemGray6.cgColor
        //AIToken.layer.cornerRadius = 10
        setValues()
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

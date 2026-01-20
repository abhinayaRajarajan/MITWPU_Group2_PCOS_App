//
//  NutritionHeader.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class NutritionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var nutritionCard: UIView!
    
    @IBOutlet weak var proteinView: UIView!
    @IBOutlet weak var carbsView: UIView!
    
    @IBOutlet weak var fatsView: UIView!
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
        setValues()
    }
    
    func setValues(){
        for index in FoodLogDataSource.todaysMeal.indices {
            var food = FoodLogDataSource.todaysMeal[index]
            if !food.isLogged {
                calories += food.calories
                fats += food.fatsContent
                protein += food.proteinContent
                carbs += food.carbsContent

                // mark as logged on the actual element
                food.isLogged = true // or food.toggleLog()
                let ptr = FoodLogDataSource.sampleFoods.firstIndex(where: {$0.id == food.id})
                FoodLogDataSource.sampleFoods[ptr!] = food// write back
            }
        }
        calToBeConsumed.text = "/2000kcal"
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

extension NutritionHeader {
    func subtractValues(_ food: Food) {
        // Subtract from local state variables
        calories -= food.calories
        fats -= food.fatsContent
        protein -= food.proteinContent
        carbs -= food.carbsContent
        
        // Ensure values don't go below 0
        calories = max(0, calories)
        fats = max(0, fats)
        protein = max(0, protein)
        carbs = max(0, carbs)
        
        // Update labels
        caloriesConsumed.text = "\(Int(calories))"
        fatsGm.text = "\(Int(fats))"
        proteinGm.text = "\(Int(protein))"
        carbsGm.text = "\(Int(carbs))"
        
        // Update progress bars
        fatsProgress.progress = Float(fats/60)
        carbsProgress.progress = Float(carbs/180)
        proteinProgress.progress = Float(protein/90)
        
        // Update circular progress
        progressCircle.setProgress(to: Float(calories)/2000)
    }
}

//
//  FoodDataSource.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct Food: Codable, Identifiable {
    let id: UUID
    var name: String
    var image: String?
    var timeStamp: Date
    var quantity: Double
    
    // Base macros (if not ingredient-based)
    var proteinContent: Double
    var carbsContent: Double
    var fatsContent: Double
    var fibreContent: Double
    
    // Optional override
    var customCalories: Double?
    
    // Tags
    var tags: [ImpactTags]
    
    // Ingredient list
    var ingredients: [Ingredient]? = nil
    
    var calories: Double {
            // 1: Explicit override
            if let customCalories = customCalories {
                return customCalories
            }
            
            // 2: Ingredient-based calories
            if let ingredients = ingredients {
                let total = ingredients.reduce(0) { $0 + $1.calories }
                return total.rounded(toPlaces: 2)
            }
            
            // 3: Macro-based calories
            let total = (proteinContent * 4) +
                        (carbsContent * 4) +
                        (fatsContent * 9)
            
            return total.rounded(toPlaces: 2)
        }
    
    var Insights: [String]?
}

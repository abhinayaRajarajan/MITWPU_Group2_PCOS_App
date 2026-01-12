//
//  IngredientsModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct Ingredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: Double
    var weight: Double? //add this values in datasource for testing
    
    // Macro breakdown for THIS ingredient
    var protein: Double
    var carbs: Double
    var fats: Double
    var fibre: Double
    
    var tags: [ImpactTags]
    
    // Calories for ONLY this ingredient
    var calories: Double? {
        (protein * 4) + (carbs * 4) + (fats * 9)
    }
}

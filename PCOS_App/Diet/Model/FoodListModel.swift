//
//  FoodListDataSource.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct FoodItem: Codable, Identifiable {
    var id = UUID()
    let name: String
    let calories: Int
    var image: String = "dietPlaceholder"
    let servingSize: Double
    var unit: String = "g"
    var protein: Double
    var carbs: Double
    var fat: Double
    var isSelected: Bool = false
    var desc: String = ""
    var ingredients: [Ingredient] = []
}


//
//  FoodListDataSource.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct InsulinFoodItem: Codable, Identifiable {
    var id: String = UUID().uuidString
    let name: String
    let calories: Int
    let servingSize: String
    let protein: Double
    let carbs: Double
    let fat: Double
}


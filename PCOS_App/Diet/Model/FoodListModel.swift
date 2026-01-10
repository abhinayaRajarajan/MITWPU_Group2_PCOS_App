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
    let image: String = "dietPlaceholder"
    let servingSize: String
    let protein: Double
    let carbs: Double
    let fat: Double
    var isSelected: Bool = false
    var desc: String = ""
}


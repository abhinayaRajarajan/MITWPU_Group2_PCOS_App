//
//  AIFoodItemResponse.swift
//  PCOS_App
//
//  Created by SDC-USER on 22/01/26.
//

import Foundation

struct AIIngredient: Codable {
    let name: String
    let quantity: Double
    let unit: String
    let protein: Double
    let carbs: Double
    let fats: Double
    let fibre: Double
}

struct AIFoodResponse: Codable {
    let name: String
    let calories: Int
    let servingSize: Double
    let unit: String
    let protein: Double
    let carbs: Double
    let fat: Double
    let desc: String
    let ingredients: [AIIngredient]
}

//struct AIFoodItemResponse: Codable {
//    let name: String
//    let calories: Int
//    let servingSize: Double
//    let unit: String
//    let protein: Double
//    let carbs: Double
//    let fat: Double
//    let desc: String
//    let ingredients: [Ingredient]
//}

struct OpenFoodFactsResponse: Codable {
    let products: [OFFAPIProduct]
}

struct OFFAPIProduct: Codable {
    let product_name: String?
    let nutriments: OFFAPINutriments?
}

struct OFFAPINutriments: Codable {
    let proteins_100g: Double?
    let carbohydrates_100g: Double?
    let fat_100g: Double?
    let fiber_100g: Double?
}

//
//  AIOutputTypes.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/03/26.
//

import Foundation

//MARK: meal reccomendation system
struct MealRecommendationOutput: Codable {
    var observationLine: String
    var foods: [FoodCard]
}

struct FoodCard: Codable {
    var name: String
    var primaryMacro: String
    var impactTag: String
    var colorHint: String
}

//MARK: daily goals output
struct DailyGoalsOutput: Codable {
    var goals: [GoalCard]
}

struct GoalCard: Codable {
    var title: String
    var sentence: String
    var category: String
}

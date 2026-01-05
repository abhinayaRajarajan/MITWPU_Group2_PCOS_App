//
//  RecommendationsModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import Foundation

struct DailyFoodFeatures: Codable, Identifiable {
    let id: UUID
    let date: Date

    let totalCalories: Double
    let proteinRatio: Double
    let carbRatio: Double
    let fatRatio: Double
    let fibreGrams: Double

    let impactTagCounts: [ImpactTags: Int]

    let highGlycemicMeals: Int
    let insulinSpikingMeals: Int
    let ultraProcessedMeals: Int
}
struct DailySymptomFeatures: Codable, Identifiable {
    let id: UUID
    let date: Date

    let acne: Bool
    let bloating: Bool
    let fatigue: Bool
    let anxiety: Bool

    let symptomLoadScore: Int
}
struct WeeklyWorkoutFeatures: Codable, Identifiable {
    let id: UUID
    let weekStart: Date

    let workoutCount: Int
    let totalMinutes: Int
    let strengthSessions: Int
    let cardioSessions: Int
}
enum RecommendationCategory: String, Codable {
    case nutrition
    case foodPattern
    case symptoms
    case workout
    case adherence
    case progress
}

struct Recommendation: Codable, Identifiable {
    let id: UUID
    let userId: UUID

    let category: RecommendationCategory
    let priority: Int          // 1 = low, 3 = high
    let confidence: Double     // 0.0 – 1.0

    let title: String
    let summary: String

    let evidence: [String]
    let actions: [String]

    let navigationTarget: String
    let createdAt: Date
    let validUntil: Date
}

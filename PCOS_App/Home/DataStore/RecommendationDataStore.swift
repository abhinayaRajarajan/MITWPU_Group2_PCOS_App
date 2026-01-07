//
//  RecommendationDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import Foundation

let recommendations: [Recommendation] = [

    Recommendation(
        id: UUID(),
        userId: UUID(),
        category: .nutrition,
        priority: 3,
        confidence: 0.74,
        title: "Protein intake is lower than recommended",
        summary: "Your protein intake has been consistently below the suggested range for PCOS.",
        evidence: [
            "Protein averaged 15–16% of total calories",
            "Fatigue logged on multiple days"
        ],
        actions: [
            "Add a protein-rich breakfast",
            "Aim for 20–25g protein per meal"
        ],
        navigationTarget: "DietProteinDetail",
        createdAt: Date(),
        validUntil: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    ),

    Recommendation(
        id: UUID(),
        userId: UUID(),
        category: .foodPattern,
        priority: 3,
        confidence: 0.78,
        title: "Sugar-heavy days align with acne logs",
        summary: "Acne was logged after days with high-glycemic foods.",
        evidence: [
            "High-glycemic meals logged on 2 days",
            "Acne reported within 48 hours"
        ],
        actions: [
            "Reduce refined carbs on acne-heavy days",
            "Choose low-glycemic snacks"
        ],
        navigationTarget: "FoodImpactAnalysis",
        createdAt: Date(),
        validUntil: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    ),

    Recommendation(
        id: UUID(),
        userId: UUID(),
        category: .workout,
        priority: 2,
        confidence: 0.65,
        title: "Workout consistency dipped this week",
        summary: "Movement supports insulin balance and mood regulation.",
        evidence: [
            "Only 2 workouts logged this week",
            "Total activity time: 55 minutes"
        ],
        actions: [
            "Aim for 3 short sessions per week",
            "Include strength training if possible"
        ],
        navigationTarget: "WorkoutWeeklySummary",
        createdAt: Date(),
        validUntil: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    )
]


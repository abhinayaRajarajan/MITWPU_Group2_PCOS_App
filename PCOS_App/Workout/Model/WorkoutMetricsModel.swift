//
//  WorkoutMetricsModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

import SwiftUI

// MARK: - Goal Type
enum GoalType {
    case calories
    case steps
    case duration
    
    var title: String {
        switch self {
        case .calories: return "Calories Burnt"
        case .steps: return "Steps Taken"
        case .duration: return "Workout Duration"
        }
    }
    
    var color: UIColor {
        switch self {
        case .calories: return UIColor(hex: "C796FF")
        case .steps: return UIColor(hex: "FFEBA2")
        case .duration: return UIColor(hex: "B2E8FF")
        }
        
            }
    var gradient: LinearGradient {
            switch self {
            case .calories:
                return LinearGradient(
                    colors: [Color(hex: "C796FF"), Color(hex: "9F6BFF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .steps:
                return LinearGradient(
                    colors: [Color(hex: "FFEBA2"), Color(hex: "FFD166")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .duration:
                return LinearGradient(
                    colors: [Color(hex: "B2E8FF"), Color(hex: "6ECFFF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }
    
    
    var recommendedValue: Double {
        switch self {
        case .calories: return 300.0
        case .steps: return 8000.0
        case .duration: return 120.0  // 2 hours = 120 minutes
        }
    }
    
    var unit: String {
        switch self {
        case .calories: return "cal"
        case .steps: return "steps"
        case .duration: return "min"
        }
    }
}

// MARK: - Time Range
enum WorkoutChartTimeRange: Int {
    //case day = 0
    case week = 0
    case month = 1
    case year = 2
}

// MARK: - Chart Data Point
struct WorkoutChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}

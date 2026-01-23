//
//  UserModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import Foundation

struct UserProfile {
    let name: String
    let dateOfBirth: Date
    let heightInCm: Double
    let weightInKg: Double

    let pcosType: PCOSType
    let metabolicProfile: MetabolicProfile

    let activityLevel: ActivityLevel
   
}



enum ActivityLevel {
    case sedentary
    case lightlyActive
    case active
    case veryActive
}


enum PCOSType: String, Codable {
    case insulinResistant
    case lean
    case inflammatory
    case mixed
}
struct MetabolicProfile: Codable {
    let insulinResistance: Bool
    
    let diabetes: Bool
    let highCholesterol: Bool
}


enum BMICategory {
    case underweight
    case normal
    case overweight
    case obese
}
//computed and not input
enum InsulinRiskLevel {
    case low
    case moderate
    case high
}

extension UserProfile {

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var bmi: Double {
        let heightInMeters = heightInCm / 100
        return weightInKg / (heightInMeters * heightInMeters)
    }

    var bmiCategory: BMICategory {
        switch bmi {
        case ..<18.5:
            return .underweight
        case 18.5..<25:
            return .normal
        case 25..<30:
            return .overweight
        default:
            return .obese
        }
    }
}

struct DietGoals {
    let proteinGrams: Int
    let carbsGrams: Int
    let fatsGrams: Int
}
struct WorkoutGoals {
    let workoutMinutesPerDay: Int
    let caloriesBurnedPerDay: Int
    let stepsPerDay: Int
}
struct UserGoals {
    let diet: DietGoals
    let workout: WorkoutGoals
}
struct GoalEngine {
    static func computeInsulinRisk(for user: UserProfile) -> InsulinRiskLevel {
        
        // Explicit diagnoses override everything
        if user.metabolicProfile.diabetes  {
            return .high
        }
        
        if user.metabolicProfile.insulinResistance {
            return .high
        }
        
        // PCOS type influence
        if user.pcosType == .insulinResistant {
            return .high
        }
        
        // BMI-based scaling
        switch user.bmiCategory {
        case .obese:
            return .high
        case .overweight:
            return .moderate
        default:
            return .low
        }
    }
    private static func estimateCalories(for user: UserProfile) -> Int {
        // Mifflin–St Jeor (female)
        let bmr =
        (10 * user.weightInKg) +
        (6.25 * user.heightInCm) -
        (5 * Double(user.age)) -
        161
        
        let activityMultiplier: Double
        switch user.activityLevel {
        case .sedentary: activityMultiplier = 1.2
        case .lightlyActive: activityMultiplier = 1.375
        case .active: activityMultiplier = 1.55
        case .veryActive: activityMultiplier = 1.725
        }
        
        return Int(bmr * activityMultiplier)
    }
    private static func computeDietGoals(for user: UserProfile) -> DietGoals {
        
        let insulinRisk = computeInsulinRisk(for: user)
        let calories = estimateCalories(for: user)
        
        // Protein
        let proteinFactor: Double
        switch insulinRisk {
        case .low: proteinFactor = 1.5
        case .moderate: proteinFactor = 1.7
        case .high: proteinFactor = 1.9
        }
        
        let proteinGrams = Int(user.weightInKg * proteinFactor)
        
        //Fat (25% calories)
        let fatCalories = Double(calories) * 0.25
        let fatsGrams = Int(fatCalories / 9)
        
        // Carbs(remaining calories) 
        let proteinCalories = Double(proteinGrams) * 4
        let remainingCalories = Double(calories) - proteinCalories - fatCalories
        let carbsGrams = Int(remainingCalories / 4)
        
        return DietGoals(
            proteinGrams: proteinGrams,
            carbsGrams: carbsGrams,
            fatsGrams: fatsGrams
        )
    }
    private static func computeWorkoutGoals(for user: UserProfile) -> WorkoutGoals {
        
        let calories = estimateCalories(for: user)
        
        let steps: Int
        let minutes: Int
        
        switch user.activityLevel {
        case .sedentary:
            steps = 6000
            minutes = 20
        case .lightlyActive:
            steps = 7500
            minutes = 30
        case .active:
            steps = 9000
            minutes = 40
        case .veryActive:
            steps = 10000
            minutes = 50
        }
        
        let caloriesBurned = Int(Double(calories) * 0.12)
        
        return WorkoutGoals(
            workoutMinutesPerDay: minutes,
            caloriesBurnedPerDay: caloriesBurned,
            stepsPerDay: steps
        )
    }
    
    static func generateGoals(for user: UserProfile) -> UserGoals {

        let dietGoals = computeDietGoals(for: user)
        let workoutGoals = computeWorkoutGoals(for: user)

        return UserGoals(
            diet: dietGoals,
            workout: workoutGoals
        )
    }
//WHO baseline -> Added sugar ≤ 10% of total calories
    //sensitivity threshold
//    Low insulin risk      → 10–12% of calories
//    Moderate insulin risk → 8 to 10% of calories
//    High insulin risk     → 5–8% of calories
    

}


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

    let dietPattern: DietPattern
    let activityLevel: ActivityLevel
    let primaryFocus: PrimaryFocus?
}

enum DietPattern {
    case balanced
    case highSugar
    case irregular
    case unsure
}

enum ActivityLevel {
    case sedentary
    case lightlyActive
    case active
    case veryActive
}

enum PrimaryFocus {
    case cycleRegularity
    case weightManagement
    case acneOrHair
    case energy
    case unsure
}

enum BMICategory {
    case underweight
    case normal
    case overweight
    case obese
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

    static func generateGoals(for user: UserProfile) -> UserGoals {

        let dietGoals: DietGoals
        let workoutGoals: WorkoutGoals

        // MARK: Diet Goals
        switch user.dietPattern {
        case .balanced:
            dietGoals = DietGoals(
                proteinGrams: 90,
                carbsGrams: 180,
                fatsGrams: 60
            )

        case .highSugar:
            dietGoals = DietGoals(
                proteinGrams: 100,
                carbsGrams: 150,
                fatsGrams: 65
            )

        case .irregular:
            dietGoals = DietGoals(
                proteinGrams: 95,
                carbsGrams: 160,
                fatsGrams: 60
            )

        case .unsure:
            dietGoals = DietGoals(
                proteinGrams: 85,
                carbsGrams: 170,
                fatsGrams: 60
            )
        }

        // MARK: Workout Goals
        switch user.activityLevel {
        case .sedentary:
            workoutGoals = WorkoutGoals(
                workoutMinutesPerDay: 15,
                caloriesBurnedPerDay: 150,
                stepsPerDay: 4000
            )

        case .lightlyActive:
            workoutGoals = WorkoutGoals(
                workoutMinutesPerDay: 25,
                caloriesBurnedPerDay: 250,
                stepsPerDay: 6000
            )

        case .active:
            workoutGoals = WorkoutGoals(
                workoutMinutesPerDay: 40,
                caloriesBurnedPerDay: 350,
                stepsPerDay: 8000
            )

        case .veryActive:
            workoutGoals = WorkoutGoals(
                workoutMinutesPerDay: 50,
                caloriesBurnedPerDay: 450,
                stepsPerDay: 10000
            )
        }

        return UserGoals(diet: dietGoals, workout: workoutGoals)
    }
}


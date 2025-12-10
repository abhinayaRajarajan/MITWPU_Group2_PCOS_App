//
//  ExploreRoutineDatastore.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/12/25.
//
import Foundation

class RoutineDataStore {
    static let shared = RoutineDataStore()
    private init() {}

    // MARK: - Predefined routines for Explore section
    let predefinedRoutines: [Routine] = [
        // 1. WARM UP
        Routine(
            id:UUID(),
            name: "Warm-Up",
            exercises: [
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Jumping Jacks" }!,
                    durationSeconds: 180     // 3 mins
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Cat-Cow Stretch" }!,
                    durationSeconds: 90
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "World's Greatest Stretch" }!,
                    durationSeconds: 120
                )
            ],
            thumbnailImageName: "plank"
        ),

        // 2. HIIT
        Routine(
            id:UUID(),
            name: "HIIT",
            exercises: [
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Burpees" }!,
                    durationSeconds: 300      // 5 mins
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Mountain Climbers" }!,
                    durationSeconds: 300
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "High Knees" }!,
                    durationSeconds: 300
                )
            ],
            thumbnailImageName: "plank"
        ),

        // 3. YOGA / MOBILITY
        Routine(
            id:UUID(),
            name: "Yoga",
            exercises: [
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Cat-Cow Stretch" }!,
                    durationSeconds: 180
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Hip Circles" }!,
                    durationSeconds: 180
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "World's Greatest Stretch" }!,
                    durationSeconds: 240
                )
            ],
            thumbnailImageName: "warm-up"
        ),

        // 4. LEG DAY
        Routine(
            id:UUID(),
            name: "Leg Day",
            exercises: [
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Barbell Squat" }!,
                    numberOfSets: 4,
                    reps: 8,
                    weightKg: 30
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Leg Press" }!,
                    numberOfSets: 3,
                    reps: 10,
                    weightKg: 50
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Lunges" }!,
                    numberOfSets: 3,
                    reps: 12
                )
            ],
            thumbnailImageName: "warm-up"
        ),

        // 5. UPPER BODY
        Routine(
            id:UUID(),
            name: "Upper Body",
            exercises: [
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Bench Press" }!,
                    numberOfSets: 4,
                    reps: 8,
                    weightKg: 25
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Lat Pulldown" }!,
                    numberOfSets: 3,
                    reps: 10,
                    weightKg: 30
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Dumbbell Shoulder Press" }!,
                    numberOfSets: 3,
                    reps: 10,
                    weightKg: 10
                )
            ],
            thumbnailImageName: "warm-up"
        ),

        // 6. STRETCHING
        Routine(
            id:UUID(),
            name: "Stretching",
            exercises: [
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Hip Circles" }!,
                    durationSeconds: 120
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Cat-Cow Stretch" }!,
                    durationSeconds: 120
                ),
                RoutineExercise(
                    exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "World's Greatest Stretch" }!,
                    durationSeconds: 180
                )
            ],
            thumbnailImageName: "plank"
        )
    ]
}


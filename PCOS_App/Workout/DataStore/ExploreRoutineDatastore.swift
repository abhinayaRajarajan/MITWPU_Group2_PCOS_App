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
        // MARK: - Workout Paths (PCOS-guided routines)

       

            // 1️⃣ LOW ENERGY MOVEMENT
            Routine(
                id: UUID(),
                name: "Low Energy Movement",
                exercises: [
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Cat-Cow Stretch" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Hip Circles" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Glute Bridge" }!,
                        numberOfSets: 2,
                        reps: 12
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "World's Greatest Stretch" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Tree Pose" }!,
                        durationSeconds: 60
                    )
                ],
                createdAt: Date(),
                thumbnailImageName: "routine_11",
                routineTagline: "When fatigue is high and your body needs gentle support",
                routineDescription: "Designed for days of low energy and physical fatigue, this routine prioritizes gentle activation and mobility to avoid excessive cortisol spikes. Slow, controlled movement supports hormonal balance, improves circulation, and encourages recovery without overloading the nervous system—making it ideal for PCOS users on depleted days."
            ),

            // 2️⃣ CALM & STEADY
            Routine(
                id: UUID(),
                name: "Calm and Steady",
                exercises: [
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Cat-Cow Stretch" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "World's Greatest Stretch" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Plank" }!,
                        durationSeconds: 45
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Face Pulls" }!,
                        numberOfSets: 2,
                        reps: 12
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Seated Cable Row" }!,
                        numberOfSets: 2,
                        reps: 10
                    )
                ],
                createdAt: Date(),
                thumbnailImageName: "routine9",
                routineTagline: "When stress or overwhelm calls for slow, stabilizing movement",
                routineDescription: "This routine supports stress regulation by emphasizing steady, grounding movements that help calm the nervous system. By reducing sympathetic overactivation and cortisol output, it aids hormonal stability while improving posture and muscular control—especially useful during mentally overwhelming or emotionally taxing days."
            ),

            // 3️⃣ BUILD & BURN
            Routine(
                id: UUID(),
                name: "Build and Burn",
                exercises: [
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Barbell Squat" }!,
                        numberOfSets: 3,
                        reps: 8
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Dumbbell Romanian Deadlift" }!,
                        numberOfSets: 3,
                        reps: 10
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Bench Press" }!,
                        numberOfSets: 3,
                        reps: 8
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Lat Pulldown" }!,
                        numberOfSets: 3,
                        reps: 10
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Mountain Climbers" }!,
                        durationSeconds: 60
                    )
                ],
                createdAt: Date(),
                thumbnailImageName: "routine10",
                routineTagline: "For days you feel motivated and ready to challenge your body",
                routineDescription: "Built for high-motivation days, this routine focuses on compound strength movements that improve insulin sensitivity, lean muscle mass, and metabolic efficiency—key factors in PCOS management. Intensity is purposeful and structured to stimulate adaptation without unnecessary cortisol overload."
            ),

            // 4️⃣ LIGHT & FLOW
            Routine(
                id: UUID(),
                name: "Light and Flow",
                exercises: [
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Hip Circles" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "World's Greatest Stretch" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Cat-Cow Stretch" }!,
                        durationSeconds: 120
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Step-Up on Chair" }!,
                        numberOfSets: 2,
                        reps: 10
                    ),
                    RoutineExercise(
                        exercise: ExerciseDataStore.shared.allExercises.first { $0.name == "Jumping Jacks" }!,
                        durationSeconds: 60
                    )
                ],
                createdAt: Date(),
                thumbnailImageName: "routine_12",
                routineTagline: "When bloating or heaviness makes lighter, flowing movement feel better",
                routineDescription: "This routine emphasizes flow-based movement to support digestion, circulation, and lymphatic drainage—helping relieve bloating and pelvic heaviness common in PCOS. Gentle transitions reduce physical discomfort while keeping the body active without adding stress load."
            )
        ]
}


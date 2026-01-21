//
//  CompletedWorkouts.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 16/01/26.
//
import Foundation

final class CompletedWorkoutsDataStore {

    static let shared = CompletedWorkoutsDataStore()
    private init() {}

    private let key = "completed_workouts_v1"

    // MARK: - Save
    func save(_ workout: CompletedWorkout) {
        var all = loadAll()
        all.append(workout)
        persist(all)
    }

    // MARK: - Load
    func loadAll() -> [CompletedWorkout] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let workouts = try? JSONDecoder().decode([CompletedWorkout].self, from: data)
        else { return [] }

        return workouts
    }

    // MARK: - Queries
    func workout(on date: Date) -> CompletedWorkout? {
        let calendar = Calendar.current
        return loadAll().first {
            calendar.isDate($0.date, inSameDayAs: date)
        }
    }

    func hasCompletedWorkout(on date: Date) -> Bool {
        guard let workout = workout(on: date) else { return false }
        return workout.isFullyCompleted
    }

    // MARK: - Persist
    private func persist(_ workouts: [CompletedWorkout]) {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
extension CompletedWorkoutsDataStore {

    func seedMockWorkouts() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Avoid duplicating mock data
        if hasCompletedWorkout(on: today) { return }

        // MARK: - Exercises
        let squat = Exercise(
            name: "Bodyweight Squats",
            muscleGroup: .legs,
            equipment: .none,
            image: "barbell_squat",
            level: "Beginner",
            tempo: "2-1-2",
            form: ["Chest up", "Knees out"],
            variations: [],
            commonMistakes: []
        )

        let pushUps = Exercise(
            name: "Lat Pulldown",
            muscleGroup: .chest,
            equipment: .none,
            image: "lat_pulldown",
            level: "Beginner",
            tempo: "2-0-2",
            form: ["Straight body line", "Elbows 45°"],
            variations: [],
            commonMistakes: []
        )

        let plank = Exercise(
            name: "Plank Hold",
            muscleGroup: .core,
            equipment: .none,
            image: "plank",
            level: "Beginner",
            tempo: "Hold steady",
            form: ["Neutral spine", "Core tight"],
            variations: [],
            commonMistakes: []
        )

        let jumpingJacks = Exercise(
            name: "Jumping Jacks",
            muscleGroup: .fullBody,
            equipment: .none,
            image: "jumping_jacks",
            level: "Beginner",
            tempo: "Fast-paced",
            form: ["Soft knees", "Controlled arms"],
            variations: [],
            commonMistakes: []
        )

        // MARK: - Sets
        let squatSets = [
            ExerciseSet(setNumber: 1, reps: 12, weightKg: 0, restTimerSeconds: 60, durationSeconds: nil, completionState: .completed),
            ExerciseSet(setNumber: 2, reps: 12, weightKg: 0, restTimerSeconds: 60, durationSeconds: nil, completionState: .completed)
        ]

        let pushUpSets = [
            ExerciseSet(setNumber: 1, reps: 10, weightKg: 0, restTimerSeconds: 60, durationSeconds: nil, completionState: .completed),
            ExerciseSet(setNumber: 2, reps: 8, weightKg: 0, restTimerSeconds: 60, durationSeconds: nil, completionState: .completed)
        ]

        let plankSets = [
            ExerciseSet(setNumber: 1, reps: 0, weightKg: 0, restTimerSeconds: 30, durationSeconds: 45, completionState: .completed),
            ExerciseSet(setNumber: 2, reps: 0, weightKg: 0, restTimerSeconds: 30, durationSeconds: 40, completionState: .completed)
        ]

        let jumpingJackSets = [
            ExerciseSet(setNumber: 1, reps: 0, weightKg: 0, restTimerSeconds: 30, durationSeconds: 60, completionState: .completed)
        ]

        // MARK: - Workout Exercises
        let workoutExercises = [
            WorkoutExercise(id: UUID(), exercise: squat, sets: squatSets, notes: nil),
            WorkoutExercise(id: UUID(), exercise: pushUps, sets: pushUpSets, notes: nil),
            WorkoutExercise(id: UUID(), exercise: plank, sets: plankSets, notes: nil),
            WorkoutExercise(id: UUID(), exercise: jumpingJacks, sets: jumpingJackSets, notes: nil)
        ]

        // MARK: - Completed Workout
        let completedWorkout = CompletedWorkout(
            routineName: "Full Body Beginner",
            date: today,
            durationSeconds: 1800, // 30 mins
            exercises: workoutExercises
        )

        save(completedWorkout)
    }

}

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


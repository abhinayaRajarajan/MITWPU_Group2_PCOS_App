//
//  DailyActivityDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation

class DailyActivityDataStore {
    static let shared = DailyActivityDataStore()
    
    private let userDefaults = UserDefaults.standard
    private let key = "dailyActivities"
    
    private init() {
        // Load sample data on first launch
        if loadAll().isEmpty {
            populateSampleData()
        }
    }
    
    // MARK: - CRUD Operations
    
    func loadAll() -> [DailyActivity] {
        guard let data = userDefaults.data(forKey: key),
              let activities = try? JSONDecoder().decode([DailyActivity].self, from: data) else {
            return []
        }
        return activities.sorted { $0.date > $1.date }
    }
    
    func save(_ activity: DailyActivity) {
        var activities = loadAll()
        
        // Remove existing entry for same date
        let calendar = Calendar.current
        activities.removeAll { calendar.isDate($0.date, inSameDayAs: activity.date) }
        
        // Add new entry
        activities.append(activity)
        
        // Save
        if let data = try? JSONEncoder().encode(activities) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func getActivity(for date: Date) -> DailyActivity? {
        let calendar = Calendar.current
        return loadAll().first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func updateOrCreateActivity(for date: Date, steps: Int? = nil, calories: Int? = nil, duration: Int? = nil) {
        var activity = getActivity(for: date) ?? DailyActivity(date: date)
        
        if let steps = steps {
            activity.steps += steps
        }
        if let calories = calories {
            activity.caloriesBurned += calories
        }
        if let duration = duration {
            activity.activeDurationSeconds += duration
        }
        
        save(activity)
    }
    
    // MARK: - Sample Data
    
    private func populateSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate data for last 60 days
        for dayOffset in 0..<60 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Vary the data to make it realistic
            let variance = Double.random(in: 0.7...1.3)
            
            let steps = Int(Double.random(in: 3000...10000) * variance)
            let calories = Int(Double.random(in: 150...450) * variance)
            let duration = Int(Double.random(in: 1800...5400) * variance) // 30-90 min
            
            let activity = DailyActivity(
                date: date,
                steps: steps,
                caloriesBurned: calories,
                activeDurationSeconds: duration
            )
            
            save(activity)
        }
        
        print("✅ Populated \(loadAll().count) days of sample activity data")
    }
    
    // MARK: - Sync with Workouts
    
    func syncWorkout(_ workout: CompletedWorkout) {
        let calendar = Calendar.current
        let workoutDate = calendar.startOfDay(for: workout.date)
        
        var activity = getActivity(for: workoutDate) ?? DailyActivity(date: workoutDate)
        activity.addWorkout(durationSeconds: workout.durationSeconds)
        save(activity)
    }
    
    func clearAll() {
        userDefaults.removeObject(forKey: key)
    }
}

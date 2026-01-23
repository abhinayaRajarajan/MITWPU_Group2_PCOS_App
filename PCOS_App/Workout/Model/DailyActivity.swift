//
//  DailyActivity.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation

struct DailyActivity: Codable {
    let date: Date
    var steps: Int
    var caloriesBurned: Int
    var activeDurationSeconds: Int
    
    init(date: Date, steps: Int = 0, caloriesBurned: Int = 0, activeDurationSeconds: Int = 0) {
        self.date = date
        self.steps = steps
        self.caloriesBurned = caloriesBurned
        self.activeDurationSeconds = activeDurationSeconds
    }
    
    // Helper to merge workout data into daily activity
    mutating func addWorkout(durationSeconds: Int) {
        self.activeDurationSeconds += durationSeconds
        
        // Estimate calories: ~6 cal/min
        let minutes = Double(durationSeconds) / 60.0
        self.caloriesBurned += Int(minutes * 6.0)
        
        // Estimate steps: ~110 steps/min
        self.steps += Int(minutes * 110.0)
    }
}

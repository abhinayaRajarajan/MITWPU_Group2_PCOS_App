//
//  CycleModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/02/26.
//

import Foundation

// MARK: - Core Cycle Model
struct CycleRecord: Identifiable {
    let id = UUID()
    let startDate: Date        // Period start date
    let periodLength: Int      // How many days period lasted
    let cycleLength: Int       // Total cycle length (start to next start)
    
    // Computed display label (e.g. "Aug\n2")
    var chartLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: startDate)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = dayFormatter.string(from: startDate)
        
        return "\(month)\n\(day)"
    }
    
    // Short month label for line chart (e.g. "Aug")
    var shortLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: startDate)
    }
    
    // Convert to CycleData for bar chart
    var cycleData: CycleData {
        return CycleData(
            month: chartLabel,
            cycleLength: cycleLength,
            periodLength: periodLength
        )
    }
}

// MARK: - Cycle Statistics
struct CycleStatistics {
    let averageCycleLength: Double
    let averagePeriodLength: Double
    let shortestCycle: Int
    let longestCycle: Int
    let totalCyclesRecorded: Int
    
    init(from records: [CycleRecord]) {
        totalCyclesRecorded = records.count
        
        if records.isEmpty {
            averageCycleLength = 0
            averagePeriodLength = 0
            shortestCycle = 0
            longestCycle = 0
        } else {
            averageCycleLength = Double(records.map { $0.cycleLength }.reduce(0, +)) / Double(records.count)
            averagePeriodLength = Double(records.map { $0.periodLength }.reduce(0, +)) / Double(records.count)
            shortestCycle = records.map { $0.cycleLength }.min() ?? 0
            longestCycle = records.map { $0.cycleLength }.max() ?? 0
        }
    }
}

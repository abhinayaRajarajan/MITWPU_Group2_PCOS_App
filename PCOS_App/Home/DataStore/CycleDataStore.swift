//
//  CycleDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/02/26.
//

import Foundation

// MARK: - Cycle Data Store
class CycleDataStore {
    
    // Singleton
    static let shared = CycleDataStore()
    private init() {}
    
    // MARK: - Hardcoded MVP Dummy Data
    // Realistic PCOS pattern: irregular cycles, slight period variation
    // Stored oldest → newest
    lazy var cycleRecords: [CycleRecord] = CycleDataStore.generateMVPData()
    
    private static func generateMVPData() -> [CycleRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        // Each tuple: (cycleLength, periodLength)
        // Working backwards from today — PCOS irregular pattern
        let cycleHistory: [(cycleLength: Int, periodLength: Int)] = [
            (38, 6),   // oldest — long cycle
            (32, 5),
            (40, 6),   // very long — common PCOS spike
            (27, 4),
            (35, 5),
            (29, 4),
            (36, 6),
            (31, 5),
            (33, 5),   // most recent
        ]
        
        var records: [CycleRecord] = []
        var currentDate = now
        
        // Build from newest → oldest, then reverse
        for entry in cycleHistory.reversed() {
            let record = CycleRecord(
                startDate: currentDate,
                periodLength: entry.periodLength,
                cycleLength: entry.cycleLength
            )
            records.append(record)
            
            // Step back by this cycle length for the previous one
            currentDate = calendar.date(
                byAdding: .day,
                value: -entry.cycleLength,
                to: currentDate
            ) ?? currentDate
        }
        
        // Return sorted oldest → newest
        return records.sorted { $0.startDate < $1.startDate }
    }
    
    // MARK: - Accessors
    
    // Last N cycles for charts
    func lastNCycles(_ n: Int) -> [CycleRecord] {
        return Array(cycleRecords.suffix(n))
    }
    
    // For bar chart (CycleData format)
    func barChartData(count: Int = 6) -> [CycleData] {
        return lastNCycles(count).map { $0.cycleData }
    }
    
    // For line chart (last 5 cycles)
    func lineChartData(count: Int = 5) -> [CycleRecord] {
        return lastNCycles(count)
    }
    
    // MARK: - Statistics
    var averageCycleLength: Int {
        guard !cycleRecords.isEmpty else { return 0 }
        return cycleRecords.map { $0.cycleLength }.reduce(0, +) / cycleRecords.count
    }
    
    var averagePeriodLength: Int {
        guard !cycleRecords.isEmpty else { return 0 }
        return cycleRecords.map { $0.periodLength }.reduce(0, +) / cycleRecords.count
    }
    
    var shortestCycle: Int {
        return cycleRecords.map { $0.cycleLength }.min() ?? 0
    }
    
    var longestCycle: Int {
        return cycleRecords.map { $0.cycleLength }.max() ?? 0
    }
    
    func statistics() -> CycleStatistics {
        return CycleStatistics(from: cycleRecords)
    }
}

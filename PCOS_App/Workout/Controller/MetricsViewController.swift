//
//  MetricsViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

import UIKit
import SwiftUI

class MetricsViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var goalType: GoalType = .calories
    private var dataPoints: [WorkoutChartDataPoint] = []
    private var hostingController: UIHostingController<WorkoutChartView>?
    private var currentTimeRange: WorkoutChartTimeRange = .week
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("📊 MetricsViewController loaded with goalType: \(goalType.title)")
        print("📊 Total completed workouts: \(WorkoutSessionManager.shared.completedWorkouts.count)")
        
        title = goalType.title
        navigationController?.navigationBar.prefersLargeTitles = false
        
        segmentedControl?.selectedSegmentIndex = 1  // Week
        segmentedControl?.addTarget(self, action: #selector(timeSegmentChanged(_:)), for: .valueChanged)
        
        setupStyling()
        loadData(for: .week)
        setupChart()
        updateInsights()
    }
    
    // MARK: - Actions
    @objc func timeSegmentChanged(_ sender: UISegmentedControl) {
        let range = WorkoutChartTimeRange(rawValue: sender.selectedSegmentIndex) ?? .week
        print("📊 Time range changed to: \(range)")
        currentTimeRange = range
        loadData(for: range)
        updateInsights()
    }
    
    // MARK: - Data Loading
    private func loadData(for range: WorkoutChartTimeRange) {
        currentTimeRange = range
        let calendar = Calendar.current
        let now = Date()
        var newData: [WorkoutChartDataPoint] = []
        
        print("📊 Loading data for range: \(range)")
        print("📊 Available workouts: \(WorkoutSessionManager.shared.completedWorkouts.count)")
        
        switch range {
        case .day:
            // Last 7 completed workouts (most recent)
            let allWorkouts = WorkoutSessionManager.shared.completedWorkouts
                .sorted { $0.date > $1.date }  // Most recent first
            
            let workouts = Array(allWorkouts.prefix(7).reversed())  // Take 7, then reverse for chronological order
            
            print("📊 Day view: Showing \(workouts.count) workouts")
            
            for (index, workout) in workouts.enumerated() {
                let value = getValue(from: workout)
                print("   Workout \(index + 1): \(workout.routineName) - Value: \(value)")
                
                newData.append(WorkoutChartDataPoint(
                    date: workout.date,
                    value: value,
                    label: "W\(index + 1)"
                ))
            }
            
        case .week:
            // Last 7 days
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
            
            for dayOffset in (0..<7).reversed() {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                    let value = getDailyTotal(on: date)
                    
                    print("   Day: \(dateFormatter.string(from: date)) - Value: \(value)")
                    
                    newData.append(WorkoutChartDataPoint(
                        date: date,
                        value: value,
                        label: dateFormatter.string(from: date)
                    ))
                }
            }
            
        case .month:
            // Last 4 weeks
            for weekOffset in (0..<4).reversed() {
                if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) {
                    let value = getWeeklyAverage(startingFrom: weekStart)
                    
                    print("   Week \(4 - weekOffset): Value: \(value)")
                    
                    newData.append(WorkoutChartDataPoint(
                        date: weekStart,
                        value: value,
                        label: "W\(4 - weekOffset)"
                    ))
                }
            }
            
        case .year:
            // Last 12 months
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            for monthOffset in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) {
                    let value = getMonthlyAverage(in: date)
                    
                    print("   Month: \(dateFormatter.string(from: date)) - Value: \(value)")
                    
                    newData.append(WorkoutChartDataPoint(
                        date: date,
                        value: value,
                        label: dateFormatter.string(from: date)
                    ))
                }
            }
        }
        
        self.dataPoints = newData.sorted { $0.date < $1.date }
        
        print("📊 Total data points created: \(self.dataPoints.count)")
        if !self.dataPoints.isEmpty {
            print("📊 Sample data point: \(self.dataPoints[0].label) = \(self.dataPoints[0].value)")
        }
        
        updateChart()
    }
    
    // MARK: - Data Helpers
    private func getValue(from workout: CompletedWorkout) -> Double {
        let durationMinutes = Double(workout.durationSeconds) / 60.0
        
        switch goalType {
        case .calories:
            // Estimate: 5-7 calories per minute of exercise
            // More accurate: could vary by intensity
            return durationMinutes * 6.0
            
        case .steps:
            // Estimate: 100-120 steps per minute
            // This is a rough estimate - ideally you'd track actual steps
            return durationMinutes * 110.0
            
        case .duration:
            // Direct value in minutes
            return durationMinutes
        }
    }
    
    private func getDailyTotal(on date: Date) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dayWorkouts = WorkoutSessionManager.shared.completedWorkouts.filter {
            $0.date >= startOfDay && $0.date < endOfDay
        }
        
        print("      Found \(dayWorkouts.count) workouts on \(startOfDay)")
        
        return dayWorkouts.reduce(0.0) { total, workout in
            total + getValue(from: workout)
        }
    }
    
    private func getWeeklyAverage(startingFrom date: Date) -> Double {
        let calendar = Calendar.current
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: date)!
        
        let weekWorkouts = WorkoutSessionManager.shared.completedWorkouts.filter {
            $0.date >= date && $0.date < endOfWeek
        }
        
        let total = weekWorkouts.reduce(0.0) { total, workout in
            total + getValue(from: workout)
        }
        
        return weekWorkouts.isEmpty ? 0 : total / 7.0
    }
    
    private func getMonthlyAverage(in date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) else {
            return 0
        }
        
        let monthWorkouts = WorkoutSessionManager.shared.completedWorkouts.filter {
            $0.date >= startOfMonth && $0.date < endOfMonth
        }
        
        let total = monthWorkouts.reduce(0.0) { total, workout in
            total + getValue(from: workout)
        }
        
        let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
        return daysInMonth > 0 ? total / Double(daysInMonth) : 0
    }
    
    // MARK: - View Setup
    private func setupChart() {
        guard let chartView = chartView else {
            print("❌ chartView outlet is nil!")
            return
        }
        
        print("📊 Setting up chart with \(dataPoints.count) data points")
        
        let swiftUIView = WorkoutChartView(
            dataPoints: dataPoints,
            goalType: goalType,
            timeRange: currentTimeRange
        )
        let hosting = UIHostingController(rootView: swiftUIView)
        
        addChild(hosting)
        hosting.view.frame = chartView.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.view.backgroundColor = .clear
        
        chartView.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        
        self.hostingController = hosting
        
        print("✅ Chart setup complete")
    }
    
    private func updateChart() {
        print("📊 Updating chart with \(dataPoints.count) data points")
        
        let swiftUIView = WorkoutChartView(
            dataPoints: dataPoints,
            goalType: goalType,
            timeRange: currentTimeRange
        )
        hostingController?.rootView = swiftUIView
    }
    
    private func setupStyling() {
        chartView?.layer.cornerRadius = 16
        chartView?.clipsToBounds = true
        chartView?.backgroundColor = .white
        contentView?.layer.cornerRadius = 16
    }
    
    private func updateInsights() {
        contentLabel?.text = getImportanceText()
    }
    
    private func getImportanceText() -> String {
        switch goalType {
        case .calories:
            return "Regular calorie burning through exercise helps improve insulin sensitivity and supports healthy weight management in PCOS."
        case .steps:
            return "Daily step goals help maintain consistent physical activity, which is crucial for managing PCOS symptoms and metabolic health."
        case .duration:
            return "Consistent workout duration builds endurance and helps regulate hormones, both essential for managing PCOS effectively."
        }
    }
}

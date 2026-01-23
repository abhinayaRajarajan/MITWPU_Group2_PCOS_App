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
        
        print("MetricsViewController loaded with goalType: \(goalType.title)")
        
        title = goalType.title
        navigationController?.navigationBar.prefersLargeTitles = false
        
        segmentedControl?.selectedSegmentIndex = 0  // Week
        segmentedControl?.addTarget(self, action: #selector(timeSegmentChanged(_:)), for: .valueChanged)
        
        setupStyling()
        loadData(for: .week)
        setupChart()
        updateInsights()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData(for: currentTimeRange)
        updateChart()
        updateInsights()
    }
    
    @objc func timeSegmentChanged(_ sender: UISegmentedControl) {
        let range = WorkoutChartTimeRange(rawValue: sender.selectedSegmentIndex) ?? .week
        print("Time range changed to: \(range)")
        currentTimeRange = range
        loadData(for: range)
        updateChart()
        updateInsights()
    }
    
    // MARK: - Data Loading
    private func loadData(for range: WorkoutChartTimeRange) {
        currentTimeRange = range
        let calendar = Calendar.current
        let now = Date()
        var newData: [WorkoutChartDataPoint] = []
        
        let activities = DailyActivityDataStore.shared.loadAll()
        print("Found \(activities.count) activities in data store")
        
        switch range {
        case .week:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            
            for offset in (0..<7).reversed() {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else { continue }
                
                let value: Double
                if let activity = activities.first(where: {
                    calendar.isDate($0.date, inSameDayAs: date)
                }) {
                    value = metricValue(from: activity)
                } else {
                    value = 0
                }
                
                newData.append(
                    WorkoutChartDataPoint(
                        date: date,
                        value: value,
                        label: formatter.string(from: date)
                    )
                )
            }
            
        case .month:
            // Last 4 weeks - weekly averages
            for weekOffset in (0..<4).reversed() {
                guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) else { continue }
                let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
                
                // Get all activities in this week
                let weekActivities = activities.filter {
                    $0.date >= weekStart && $0.date < weekEnd
                }
                
                // Calculate average
                let total = weekActivities.reduce(0.0) { $0 + metricValue(from: $1) }
                let average = weekActivities.isEmpty ? 0 : total / 7.0
                
                newData.append(
                    WorkoutChartDataPoint(
                        date: weekStart,
                        value: average,
                        label: "W\(4 - weekOffset)"
                    )
                )
            }
            
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            
            for monthOffset in (0..<12).reversed() {
                guard let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
                
                let components = calendar.dateComponents([.year, .month], from: date)
                guard let monthStart = calendar.date(from: components),
                      let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { continue }
                
                // Get all activities in this month
                let monthActivities = activities.filter {
                    $0.date >= monthStart && $0.date < monthEnd
                }
                
                // Calculate average
                let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
                let total = monthActivities.reduce(0.0) { $0 + metricValue(from: $1) }
                let average = total / Double(daysInMonth)
                
                newData.append(
                    WorkoutChartDataPoint(
                        date: monthStart,
                        value: average,
                        label: formatter.string(from: monthStart)
                    )
                )
            }
        }
        
        self.dataPoints = newData.sorted { $0.date < $1.date }
        
        print("Total data points created: \(self.dataPoints.count)")
        if !self.dataPoints.isEmpty {
            print("Sample data point: \(self.dataPoints[0].label) = \(self.dataPoints[0].value)")
        }
        
        updateChart()
    }
    
    // MARK: - Data Helpers
    private func metricValue(from activity: DailyActivity) -> Double {
        switch goalType {
        case .calories:
            return Double(activity.caloriesBurned)
        case .steps:
            return Double(activity.steps)
        case .duration:
            return Double(activity.activeDurationSeconds) / 60.0
        }
    }
    
    // MARK: - View Setup
    private func setupChart() {
        guard let chartView = chartView else {
            print("chartView outlet is nil!")
            return
        }
        
        print("Setting up chart with \(dataPoints.count) data points")
        
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
        
        print("Chart setup complete")
    }
    
    private func updateChart() {
        print("Updating chart with \(dataPoints.count) data points")
        
        guard hostingController != nil else {
            setupChart()
            return
        }
        
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

//
//  SleepReportViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/02/26.
//
import SwiftUI
import UIKit

class SleepReportViewController: UIViewController {

    @IBOutlet weak var observationCard: UIView!
    @IBOutlet weak var suggestionCard: UIView!
    @IBOutlet weak var chartContainerView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var dataPoints: [SleepChartDataModel] = []
    private var hostingController: UIHostingController<AnyView>?
    private var currentTimeRange: SleepChartTimeRange = .week
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sleep Patterns"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupStyling()
        loadData(for: .week)
        setupChart()
    }
    
    // MARK: - Setup
    private func setupStyling() {
        // Background color
        view.backgroundColor = UIColor(hex: "#FCEEED")
        
        observationCard.layer.cornerRadius = 20
        observationCard.backgroundColor = .white
        suggestionCard.layer.cornerRadius = 20
        suggestionCard.backgroundColor = .white
        
        chartContainerView.layer.cornerRadius = 16
        chartContainerView.backgroundColor = .white
        chartContainerView.layer.shadowColor = UIColor.black.cgColor
        chartContainerView.layer.shadowOpacity = 0.08
        chartContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        chartContainerView.layer.shadowRadius = 8
        
        // Style segmented control
        segmentedControl.selectedSegmentTintColor = UIColor(hex: "#FE7A96")
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(hex: "#FE7A96")], for: .normal)
    }
    
    
    
    @objc func timeSegmentChanged(_ sender: UISegmentedControl) {
        print("📊 Segment changed to index: \(sender.selectedSegmentIndex)")
        
        let range = SleepChartTimeRange(rawValue: sender.selectedSegmentIndex) ?? .week
        currentTimeRange = range
        
        print("📊 Loading data for: \(range.title)")
        loadData(for: range)
    }
    
    // MARK: - Data Loading
    private func loadData(for range: SleepChartTimeRange) {
        currentTimeRange = range
        let calendar = Calendar.current
        let now = Date()
        var newData: [SleepChartDataModel] = []
        
        print("📊 Loading data for range: \(range.title)")
        
        switch range {
        case .week:
            // Last 7 days
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
            
            for dayOffset in (0..<7).reversed() {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                    let hours = getDailySleep(on: date)
                    newData.append(SleepChartDataModel(
                        date: date,
                        hours: hours,
                        label: dateFormatter.string(from: date)
                    ))
                }
            }
            
        case .month:
            // Last 4 weeks average
            for weekOffset in (0..<4).reversed() {
                if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) {
                    let hours = getWeeklyAverage(startingFrom: weekStart)
                    newData.append(SleepChartDataModel(
                        date: weekStart,
                        hours: hours,
                        label: "W\(4 - weekOffset)"
                    ))
                }
            }
            
        case .year:
            // Last 12 months average
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            for monthOffset in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) {
                    let hours = getMonthlyAverage(in: date)
                    newData.append(SleepChartDataModel(
                        date: date,
                        hours: hours,
                        label: dateFormatter.string(from: date)
                    ))
                }
            }
        }
        
        self.dataPoints = newData.sorted { $0.date < $1.date }
        
        print("📊 Loaded \(dataPoints.count) data points")
        updateChart()
    }
    
    // MARK: - Data Calculation Helpers
    private func getDailySleep(on date: Date) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        if let entry = SleepDataSource.sleepEntries.first(where: {
            $0.date >= startOfDay && $0.date < endOfDay
        }) {
            return entry.sleepHours
        }
        
        return 0
    }
    
    private func getWeeklyAverage(startingFrom date: Date) -> Double {
        let calendar = Calendar.current
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: date)!
        
        let weekEntries = SleepDataSource.sleepEntries.filter {
            $0.date >= date && $0.date < endOfWeek
        }
        
        let total = weekEntries.reduce(0.0) { $0 + $1.sleepHours }
        return weekEntries.isEmpty ? 0 : total / Double(weekEntries.count)
    }
    
    private func getMonthlyAverage(in date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) else {
            return 0
        }
        
        let monthEntries = SleepDataSource.sleepEntries.filter {
            $0.date >= startOfMonth && $0.date < endOfMonth
        }
        
        let total = monthEntries.reduce(0.0) { $0 + $1.sleepHours }
        let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
        return daysInMonth > 0 ? total / Double(daysInMonth) : 0
    }
    
    // MARK: - Chart Setup
    private func setupChart() {
        guard let chartContainerView = chartContainerView else {
            print("❌ chartContainerView outlet is nil!")
            return
        }
        
        let swiftUIView = SleepChartView(
            dataPoints: dataPoints,
            timeRange: currentTimeRange
        )
        .padding(.top, 56)  // Add extra space from top (16 for segmented control top + 40 for spacing)
        
        let hosting = UIHostingController(rootView: AnyView(swiftUIView))
        
        addChild(hosting)
        hosting.view.frame = chartContainerView.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.view.backgroundColor = .clear
        
        chartContainerView.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        
        self.hostingController = hosting
        
        print("✅ Chart setup complete")
    }

    private func updateChart() {
        print("📊 Updating chart with \(dataPoints.count) points")
        
        let swiftUIView = SleepChartView(
            dataPoints: dataPoints,
            timeRange: currentTimeRange
        )
        .padding(.top, 56)  // Add the same padding here too
        
        hostingController?.rootView = AnyView(swiftUIView)
        
        print("✅ Chart updated")
    }
}

// MARK: - UIColor Extension for Hex
//   extension UIColor {
//       convenience init(hex: String) {
//           let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//           var int: UInt64 = 0
//           Scanner(string: hex).scanHexInt64(&int)
//           let a, r, g, b: UInt64
//           switch hex.count {
//           case 3: // RGB (12-bit)
//               (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//           case 6: // RGB (24-bit)
//               (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//           case 8: // ARGB (32-bit)
//               (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//           default:
//               (a, r, g, b) = (255, 0, 0, 0)
//           }
//           self.init(
//               red: CGFloat(r) / 255,
//               green: CGFloat(g) / 255,
//               blue: CGFloat(b) / 255,
//               alpha: CGFloat(a) / 255
//           )
//       }

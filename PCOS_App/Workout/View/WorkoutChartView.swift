//
//  WorkoutChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

import SwiftUI
import Charts

struct WorkoutChartView: View {
    let dataPoints: [WorkoutChartDataPoint]
    let goalType: GoalType
    let timeRange: WorkoutChartTimeRange
    
    private var currentAverage: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.map { $0.value }.reduce(0, +) / Double(dataPoints.count)
    }
    
    private var shouldShowGoalLine: Bool {
        return timeRange != .day
    }
    
    private var displayGoalValue: Double {
        if timeRange == .week {
            return goalType.recommendedValue
        } else if timeRange == .month || timeRange == .year {
            return goalType.recommendedValue * 0.6
        } else {
            return goalType.recommendedValue
        }
    }
    
    private var maxChartValue: Double {
        let maxDataValue = dataPoints.map { $0.value }.max() ?? 0
        let referenceValue = shouldShowGoalLine ? displayGoalValue : maxDataValue
        let maxValue = max(maxDataValue, referenceValue)
        return maxValue * 1.2
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(formatValue(currentAverage))")
                            .font(.system(size: 24, weight: .bold))
                        Text(goalType.unit)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if shouldShowGoalLine {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(formatValue(displayGoalValue))")
                                .font(.system(size: 16, weight: .semibold))
                            Text(goalType.unit)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Chart
            if dataPoints.isEmpty {
                VStack {
                    Spacer()
                    Text("No data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(height: 220)
            } else {
                Chart {
                    ForEach(dataPoints) { dataPoint in
                        BarMark(
                            x: .value("Period", dataPoint.label),
                            y: .value("Amount", dataPoint.value)
                        )
                        .foregroundStyle(goalType.color.gradient)
                        .cornerRadius(6)
                    }
                    
                    if shouldShowGoalLine {
                        RuleMark(y: .value("Goal", displayGoalValue))
                            .foregroundStyle(.gray)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                }
                .frame(height: 220)
                .chartYScale(domain: 0...maxChartValue)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(formatValue(doubleValue))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gray.opacity(0.2))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
    }
    
    private func formatValue(_ value: Double) -> String {
        if goalType == .steps {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

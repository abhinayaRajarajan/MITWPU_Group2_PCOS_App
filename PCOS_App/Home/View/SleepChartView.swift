//
//  SleepChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/02/26.
//

import SwiftUI
import Charts

struct SleepChartView: View {
    let dataPoints: [SleepChartDataModel]
    let timeRange: SleepChartTimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Chart {
                ForEach(dataPoints) { point in
                    BarMark(
                        x: .value("Time", point.label),
                        y: .value("Hours", point.hours)
                    )
                    .foregroundStyle(barColor(for: point.hours))
                    .cornerRadius(6)
                }
                
                // Reference line at 7.5 hours (recommended)
                RuleMark(y: .value("Goal", 7.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(Color(hex: "#FE7A96").opacity(0.4))
            }
            .chartYScale(domain: 0...10)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 2.5, 5, 7.5, 10]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color(hex: "#FE7A96").opacity(0.1))
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.caption2)
                                .foregroundColor(Color(hex: "#8B8B8B"))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.caption)
                                .foregroundColor(Color(hex: "#8B8B8B"))
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(.horizontal, 8)
    }
    
    private func barColor(for hours: Double) -> Color {
        switch hours {
        case 7.5...10:
            // Excellent - main pink
            return Color(hex: "#FE7A96")
        case 7.0..<7.5:
            // Good - slightly lighter pink
            return Color(hex: "#FE9BAD")
        case 6.0..<7.0:
            // Fair - light pink
            return Color(hex: "#FFC2D1")
        default:
            // Poor - very light pink
            return Color(hex: "#FFE0E8")
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

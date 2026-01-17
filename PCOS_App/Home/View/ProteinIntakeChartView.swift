//
//  ProteinIntakeChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class ProteinIntakeChartView: UIView {

// MARK: - Data Model
    struct DataPoint {
        let day: String
        let value: CGFloat
        let type: LineType
    }
    
    enum LineType {
        case lastWeek
        case thisWeek
        
        var color: UIColor {
            switch self {
            case .lastWeek: return .systemGreen
            case .thisWeek: return .systemBlue
            }
        }
        
        var name: String {
            switch self {
            case .lastWeek: return "Last Week"
            case .thisWeek: return "This Week"
            }
        }
    }
    
    // MARK: - Properties
    private var dataPoints: [DataPoint] = []
    private let padding: CGFloat = 40
    private let topPadding: CGFloat = 60
    private let labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    private let valueFont = UIFont.systemFont(ofSize: 9, weight: .medium)
    private let maxValue: CGFloat = 100 // Max protein in grams
    private let yAxisStride: CGFloat = 20 // Y-axis increment
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    // MARK: - Configuration
    func configure(with data: [DataPoint]) {
        self.dataPoints = data
        setNeedsDisplay()
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !dataPoints.isEmpty else { return }
        
        let chartRect = CGRect(
            x: padding,
            y: topPadding,
            width: rect.width - padding * 2,
            height: rect.height - topPadding - padding
        )
        
        // Draw grid lines and Y-axis labels
        drawGridAndYAxis(in: chartRect)
        
        // Draw X-axis labels
        drawXAxisLabels(in: chartRect)
        
        // Group data by type
        let lastWeekData = dataPoints.filter { $0.type == .lastWeek }
        let thisWeekData = dataPoints.filter { $0.type == .thisWeek }
        
        // Draw lines
        if !lastWeekData.isEmpty {
            drawLine(data: lastWeekData, in: chartRect, color: LineType.lastWeek.color)
        }
        if !thisWeekData.isEmpty {
            drawLine(data: thisWeekData, in: chartRect, color: LineType.thisWeek.color)
        }
    }
    
    private func drawGridAndYAxis(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let numberOfLines = Int(maxValue / yAxisStride) + 1
        
        for i in 0..<numberOfLines {
            let value = CGFloat(i) * yAxisStride
            let y = rect.maxY - (value / maxValue) * rect.height
            
            // Draw horizontal grid line
            context.setStrokeColor(UIColor.systemGray5.cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y)) //change made here
            context.strokePath()
            
            // Draw Y-axis label
            let label = "\(Int(value))"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: UIColor.secondaryLabel
            ]
            let labelSize = label.size(withAttributes: attributes)
            let labelRect = CGRect(
                x: rect.minX - labelSize.width - 8,
                y: y - labelSize.height / 2,
                width: labelSize.width,
                height: labelSize.height
            )
            label.draw(in: labelRect, withAttributes: attributes)
        }
    }
    
    private func drawXAxisLabels(in rect: CGRect) {
        // Get unique days in order
        var days: [String] = []
        var seenDays = Set<String>()
        for point in dataPoints {
            if !seenDays.contains(point.day) {
                days.append(point.day)
                seenDays.insert(point.day)
            }
        }
        
        guard !days.isEmpty else { return }
        
        let spacing = rect.width / CGFloat(days.count - 1)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        for (index, day) in days.enumerated() {
            let x = rect.minX + CGFloat(index) * spacing
            let labelSize = day.size(withAttributes: attributes)
            let labelRect = CGRect(
                x: x - labelSize.width / 2,
                y: rect.maxY + 8,
                width: labelSize.width,
                height: labelSize.height
            )
            day.draw(in: labelRect, withAttributes: attributes)
        }
    }
    
    private func drawLine(data: [DataPoint], in rect: CGRect, color: UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard data.count > 1 else { return }
        
        // Get unique days for positioning
        var days: [String] = []
        var seenDays = Set<String>()
        for point in dataPoints {
            if !seenDays.contains(point.day) {
                days.append(point.day)
                seenDays.insert(point.day)
            }
        }
        
        let spacing = rect.width / CGFloat(days.count - 1)
        
        // Create path for line
        let path = UIBezierPath()
        
        for (index, point) in data.enumerated() {
            guard let dayIndex = days.firstIndex(of: point.day) else { continue }
            
            let x = rect.minX + CGFloat(dayIndex) * spacing
            let y = rect.maxY - (point.value / maxValue) * rect.height
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        // Draw line
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        path.stroke()
        
        // Draw points and values
        for point in data {
            guard let dayIndex = days.firstIndex(of: point.day) else { continue }
            
            let x = rect.minX + CGFloat(dayIndex) * spacing
            let y = rect.maxY - (point.value / maxValue) * rect.height
            
            // Draw circle
            let circlePath = UIBezierPath(
                arcCenter: CGPoint(x: x, y: y),
                radius: 6,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            context.setFillColor(color.cgColor)
            circlePath.fill()
            
            // Draw value label
            let valueText = "\(Int(point.value))"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: valueFont,
                .foregroundColor: UIColor.label
            ]
            let labelSize = valueText.size(withAttributes: attributes)
            let labelRect = CGRect(
                x: x - labelSize.width / 2,
                y: y - labelSize.height - 10,
                width: labelSize.width,
                height: labelSize.height
            )
            valueText.draw(in: labelRect, withAttributes: attributes)
        }
    }
}

// MARK: - Card View with Legend
class ProteinIntakeChartCardView: UIView {
    
    private let titleLabel = UILabel()
    private let chartView = ProteinIntakeChartView()
    private let legendStackView = UIStackView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        
        // Title
        titleLabel.text = "Noticed a low protein pattern this week"
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Chart
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        // Legend
        legendStackView.axis = .horizontal
        legendStackView.spacing = 16
        legendStackView.alignment = .center
        legendStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add legend items
        for type in [ProteinIntakeChartView.LineType.lastWeek, .thisWeek] {
            let itemView = createLegendItem(color: type.color, name: type.name)
            legendStackView.addArrangedSubview(itemView)
        }
        
        addSubview(titleLabel)
        addSubview(legendStackView)
        addSubview(chartView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
//            // Title
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // Legend
            legendStackView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            legendStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // Chart
            chartView.topAnchor.constraint(equalTo: legendStackView.bottomAnchor, constant: -12),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func createLegendItem(color: UIColor, name: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(dot)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            
            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    // MARK: - Configuration
    func configure(with data: [ProteinIntakeChartView.DataPoint]) {
        chartView.configure(with: data)
    }
}

// MARK: - Sample Data Generator
extension ProteinIntakeChartCardView {
    static func createSampleChart() -> ProteinIntakeChartCardView {
        let cardView = ProteinIntakeChartCardView()
        
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var data: [ProteinIntakeChartView.DataPoint] = []
        
        // Last week data (higher values - optimal)
        let lastWeekValues: [CGFloat] = [65, 72, 78, 70, 68, 75, 80]
        for (index, day) in weekdays.enumerated() {
            data.append(ProteinIntakeChartView.DataPoint(
                day: day,
                value: lastWeekValues[index],
                type: .lastWeek
            ))
        }
        
        // This week data (lower values)
        let thisWeekValues: [CGFloat] = [45, 50, 42, 55, 48, 52, 58]
        for (index, day) in weekdays.enumerated() {
            data.append(ProteinIntakeChartView.DataPoint(
                day: day,
                value: thisWeekValues[index],
                type: .thisWeek
            ))
        }
        
        cardView.configure(with: data)
        return cardView
    }
}


//
//  WorkoutPieChart.swift
//  PCOS_App
//
//  Created for workout visualization
//

import UIKit

class WorkoutPieChart: UIView {
    
    // Data Model
    struct WorkoutData {
        let name: String
        let value: Int
        let color: UIColor
    }
    
    // Properties
    private var segments: [WorkoutData] = []
    private var total: Int = 0
    private let donutWidth: CGFloat = 30 // Width of the donut ring
    
    //Initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    // MARK: - Configuration
    func configure(with workoutData: [WorkoutData]) {
        self.segments = workoutData
        self.total = workoutData.reduce(0) { $0 + $1.value }
        setNeedsDisplay() // Trigger redraw
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard total > 0, !segments.isEmpty else { return }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - 10 // Padding
        
        var startAngle: CGFloat = -.pi / 2 // Start at top (12 o'clock)
        
        for segment in segments {
            let percentage = CGFloat(segment.value) / CGFloat(total)
            let endAngle = startAngle + (2 * .pi * percentage)
            
            // Create the arc path
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center,
                       radius: radius,
                       startAngle: startAngle,
                       endAngle: endAngle,
                       clockwise: true)
            path.close()
            
            // Fill with color
            segment.color.setFill()
            path.fill()
            
            startAngle = endAngle
        }
        
        // Draw center circle (creates donut effect)
        let innerCircle = UIBezierPath(arcCenter: center,
                                       radius: radius - donutWidth,
                                       startAngle: 0,
                                       endAngle: 2 * .pi,
                                       clockwise: true)
        
        // Use background color or white for center
        (superview?.backgroundColor ?? UIColor.systemBackground).setFill()
        innerCircle.fill()
    }
    
    // Helper Methods
    func setDonutWidth(_ width: CGFloat) {
        // Allow customization of donut thickness
        setNeedsDisplay()
    }
}

// WorkoutPieChartView (Complete Card with Legend)
class WorkoutPieChartView: UIView {
    
    private let pieChart = WorkoutPieChart()
    private let legendStackView = UIStackView()
    //private let titleLabel = UILabel()
    private let totalLabel = UILabel()
    
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
        
        // Setup title
//        titleLabel.text = "Workout Distribution"
//        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
//        titleLabel.textColor = .label
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup total label (center of donut)
        totalLabel.font = .systemFont(ofSize: 24, weight: .bold)
        totalLabel.textColor = .label
        totalLabel.textAlignment = .center
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup pie chart
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup legend
        legendStackView.axis = .vertical
        legendStackView.spacing = 12
        legendStackView.alignment = .leading
        legendStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        //addSubview(titleLabel)
        addSubview(pieChart)
        addSubview(totalLabel)
        addSubview(legendStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
//            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Pie chart
            pieChart.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            pieChart.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            pieChart.widthAnchor.constraint(equalToConstant: 150),
            pieChart.heightAnchor.constraint(equalToConstant: 150),
            
            // Total label (center of donut)
            totalLabel.centerXAnchor.constraint(equalTo: pieChart.centerXAnchor),
            totalLabel.centerYAnchor.constraint(equalTo: pieChart.centerYAnchor),
            
            // Legend
            legendStackView.leadingAnchor.constraint(equalTo: pieChart.trailingAnchor, constant: 24),
            legendStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            legendStackView.centerYAnchor.constraint(equalTo: pieChart.centerYAnchor),
            
            // Bottom constraint
            pieChart.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with workoutData: [WorkoutPieChart.WorkoutData]) {
        // Configure pie chart
        pieChart.configure(with: workoutData)
        
        // Calculate total
        let total = workoutData.reduce(0) { $0 + $1.value }
        totalLabel.text = "\(total)"
        
        // Clear existing legend items
        legendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add legend items
        for data in workoutData {
            let legendItem = createLegendItem(color: data.color, name: data.name, value: data.value)
            legendStackView.addArrangedSubview(legendItem)
        }
    }
    
    private func createLegendItem(color: UIColor, name: String, value: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Color indicator
        let colorBox = UIView()
        colorBox.backgroundColor = color
        colorBox.layer.cornerRadius = 6
        colorBox.translatesAutoresizingMaskIntoConstraints = false
        
        // Name label
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Value label
        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = .secondaryLabel
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(colorBox)
        container.addSubview(nameLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            // Color box
            colorBox.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            colorBox.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            colorBox.widthAnchor.constraint(equalToConstant: 12),
            colorBox.heightAnchor.constraint(equalToConstant: 12),
            
            // Name label
            nameLabel.leadingAnchor.constraint(equalTo: colorBox.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            // Value label
            valueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            // Container height
            container.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return container
    }
}

//Usage Example
//extension WorkoutPieChartView {
//    
//    static func createSampleChart() -> WorkoutPieChartView {
//        let chartView = WorkoutPieChartView()
//        
//        let workoutData: [WorkoutPieChart.WorkoutData] = [
//            WorkoutPieChart.WorkoutData(name: "Cardio", value: 5, color: .systemPink),
//            WorkoutPieChart.WorkoutData(name: "Strength", value: 2, color: .systemBlue),
//            WorkoutPieChart.WorkoutData(name: "Yoga", value: 1, color: .systemPurple)
//        ]
//        
//        chartView.configure(with: workoutData)
//        
//        return chartView
//    }
//}

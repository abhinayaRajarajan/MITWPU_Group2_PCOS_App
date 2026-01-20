//
//  ChartGridView.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 19/01/26.
//
import UIKit

class ChartGridView: UIView {
    
    enum TimeRange {
        case day, week, month, year
    }
    
    var range: TimeRange = .week {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Define grid area (leave space at bottom for labels)
        let gridHeight = rect.height - 40  // Reserve 40pt for labels
        let gridRect = CGRect(x: 0, y: 0, width: rect.width, height: gridHeight)
        
        // White background for grid only
        UIColor.white.setFill()
        context.fill(gridRect)
        
        // Grid lines
        UIColor.systemGray3.setStroke()
        context.setLineWidth(1.0)
        
        // Horizontal lines (only in grid area)
        let horizontalLines = 5
        for i in 0...horizontalLines {
            let y = gridHeight * CGFloat(i) / CGFloat(horizontalLines)
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
        }
        context.strokePath()
        
        // Vertical lines (only in grid area)
        let verticalLines: Int
        switch range {
        case .day: verticalLines = 24
        case .week: verticalLines = 7
        case .month: verticalLines = 30
        case .year: verticalLines = 12
        }
        
        for i in 0...verticalLines {
            let x = rect.width * CGFloat(i) / CGFloat(verticalLines)
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: gridHeight))  // Stop at gridHeight
        }
        context.strokePath()
        
        // Draw labels below grid
        drawLabels(in: rect, gridHeight: gridHeight)
    }
    
    private func drawLabels(in rect: CGRect, gridHeight: CGFloat) {
        let labels: [String]
        let labelCount: Int
        let y = gridHeight + 10 
        switch range {
        case .day:
            labels = ["12 AM", "6 AM", "12 PM", "6 PM"]
            labelCount = 4
        case .week:
            labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            labelCount = 7
        case .month:
            labels = ["1", "8", "15", "22", "29"]
            labelCount = 5
        case .year:
            labels = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
            labelCount = 12
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.label
        ]
        
        for (index, label) in labels.enumerated() {
            let x: CGFloat
            if range == .week || range == .year {
                x = rect.width * (CGFloat(index) + 0.5) / CGFloat(labelCount)
            } else if range == .day {
                x = rect.width * CGFloat(index) / CGFloat(labelCount - 1)
            } else { // month
                let positions = [0, 7, 14, 21, 28]
                x = rect.width * CGFloat(positions[index]) / 30.0
            }
            
            // Draw BELOW the grid (positive y value)
            let y = rect.height + 15
            let size = (label as NSString).size(withAttributes: attributes)
            (label as NSString).draw(
                at: CGPoint(x: x - size.width / 2, y: y),
                withAttributes: attributes
            )
        }
    }
}

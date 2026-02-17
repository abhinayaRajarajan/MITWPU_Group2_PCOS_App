//
//  PeriodLineChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/02/26.
//

import UIKit

class PeriodLineChartView: UIView {
    
    // MARK: - Properties
    private var cycleRecords: [CycleRecord] = []
    
    private let chartPinkColor   = UIColor(red: 254/255, green: 122/255, blue: 150/255, alpha: 1.0)
    private let chartPurpleColor = UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
    private let gridColor        = UIColor.lightGray.withAlphaComponent(0.3)
    
    private let topPadding:    CGFloat = 20
    private let bottomPadding: CGFloat = 30  // space for month labels
    private let leftPadding:   CGFloat = 40  // space for y-axis labels
    private let rightPadding:  CGFloat = 16
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    // MARK: - Configure
    func configure(with records: [CycleRecord]) {
        self.cycleRecords = records
        setNeedsDisplay()   // triggers drawRect
        
        // Remove old labels, re-add after layout
        subviews.forEach { $0.removeFromSuperview() }
        
        DispatchQueue.main.async { [weak self] in
            self?.addLabels()
        }
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        guard cycleRecords.count >= 2 else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let chartWidth  = rect.width  - leftPadding - rightPadding
        let chartHeight = rect.height - topPadding  - bottomPadding
        let chartOriginX = rect.minX + leftPadding
        let chartOriginY = rect.minY + topPadding
        
        let maxValue = CGFloat(cycleRecords.map { $0.cycleLength }.max() ?? 35) + 5
        let minValue = CGFloat(max(0, (cycleRecords.map { $0.cycleLength }.min() ?? 20) - 5))
        let valueRange = maxValue - minValue
        
        // MARK: Horizontal grid lines
        let gridValues: [CGFloat] = [minValue, (minValue + maxValue) / 2, maxValue]
        
        for value in gridValues {
            let y = chartOriginY + chartHeight - ((value - minValue) / valueRange) * chartHeight
            
            // Dashed line
            context.saveGState()
            context.setStrokeColor(gridColor.cgColor)
            context.setLineWidth(1)
            context.setLineDash(phase: 0, lengths: [4, 4])
            context.move(to: CGPoint(x: chartOriginX, y: y))
            context.addLine(to: CGPoint(x: chartOriginX + chartWidth, y: y))
            context.strokePath()
            context.restoreGState()
        }
        
        // MARK: Calculate point positions
        let stepX = chartWidth / CGFloat(cycleRecords.count - 1)
        
        var cycleLengthPoints:  [CGPoint] = []
        var periodLengthPoints: [CGPoint] = []
        
        for (i, record) in cycleRecords.enumerated() {
            let x = chartOriginX + CGFloat(i) * stepX
            
            let cycleY  = chartOriginY + chartHeight
                - ((CGFloat(record.cycleLength) - minValue) / valueRange) * chartHeight
            let periodY = chartOriginY + chartHeight
                - ((CGFloat(record.periodLength + Int(minValue)) - minValue) / valueRange) * chartHeight
            
            cycleLengthPoints.append(CGPoint(x: x, y: cycleY))
            periodLengthPoints.append(CGPoint(x: x, y: periodY))
        }
        
        // MARK: Draw shaded area under cycle line
        let shadePath = UIBezierPath()
        shadePath.move(to: CGPoint(x: cycleLengthPoints[0].x,
                                   y: chartOriginY + chartHeight))
        for point in cycleLengthPoints {
            shadePath.addLine(to: point)
        }
        shadePath.addLine(to: CGPoint(x: cycleLengthPoints.last!.x,
                                      y: chartOriginY + chartHeight))
        shadePath.close()
        
        context.saveGState()
        context.addPath(shadePath.cgPath)
        context.setFillColor(chartPurpleColor.withAlphaComponent(0.15).cgColor)
        context.fillPath()
        context.restoreGState()
        
        // MARK: Draw cycle length smooth line (purple)
        drawSmoothLine(
            points: cycleLengthPoints,
            color: chartPurpleColor,
            lineWidth: 2.5,
            in: context
        )
        
        // MARK: Draw dots on cycle line
        for point in cycleLengthPoints {
            drawDot(at: point, color: chartPurpleColor, radius: 5, in: context)
        }
        
        // MARK: Draw period length line (pink, dashed)
        context.saveGState()
        context.setStrokeColor(chartPinkColor.withAlphaComponent(0.6).cgColor)
        context.setLineWidth(1.5)
        context.setLineDash(phase: 0, lengths: [6, 3])
        
        let periodPath = UIBezierPath()
        periodPath.move(to: periodLengthPoints[0])
        for i in 1..<periodLengthPoints.count {
            periodPath.addLine(to: periodLengthPoints[i])
        }
        context.addPath(periodPath.cgPath)
        context.strokePath()
        context.restoreGState()
        
        // MARK: Draw dots on period line
        for point in periodLengthPoints {
            drawDot(at: point, color: chartPinkColor, radius: 3.5, in: context)
        }
    }
    
    // MARK: - Smooth Line Helper (Catmull-Rom)
    private func drawSmoothLine(points: [CGPoint],
                                color: UIColor,
                                lineWidth: CGFloat,
                                in context: CGContext) {
        guard points.count >= 2 else { return }
        
        let path = UIBezierPath()
        path.move(to: points[0])
        
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            
            let controlPoint1 = CGPoint(x: prev.x + (curr.x - prev.x) * 0.5,
                                        y: prev.y)
            let controlPoint2 = CGPoint(x: curr.x - (curr.x - prev.x) * 0.5,
                                        y: curr.y)
            
            path.addCurve(to: curr,
                          controlPoint1: controlPoint1,
                          controlPoint2: controlPoint2)
        }
        
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.addPath(path.cgPath)
        context.strokePath()
        context.restoreGState()
    }
    
    // MARK: - Dot Helper
    private func drawDot(at point: CGPoint,
                         color: UIColor,
                         radius: CGFloat,
                         in context: CGContext) {
        let dotRect = CGRect(x: point.x - radius,
                             y: point.y - radius,
                             width: radius * 2,
                             height: radius * 2)
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        context.fillEllipse(in: dotRect)
        context.strokeEllipse(in: dotRect)
        context.restoreGState()
    }
    
    // MARK: - Add Labels
    private func addLabels() {
        guard !cycleRecords.isEmpty else { return }
        
        let rect = bounds
        let chartWidth  = rect.width  - leftPadding - rightPadding
        let chartHeight = rect.height - topPadding  - bottomPadding
        let chartOriginX = rect.minX + leftPadding
        let chartOriginY = rect.minY + topPadding
        
        let maxValue = CGFloat(cycleRecords.map { $0.cycleLength }.max() ?? 35) + 5
        let minValue = CGFloat(max(0, (cycleRecords.map { $0.cycleLength }.min() ?? 20) - 5))
        let valueRange = maxValue - minValue
        
        // Y-axis labels
        let gridValues: [CGFloat] = [minValue, (minValue + maxValue) / 2, maxValue]
        for value in gridValues {
            let y = chartOriginY + chartHeight
                - ((value - minValue) / valueRange) * chartHeight
            
            let label = makeLabel(
                text: "\(Int(value))",
                font: .systemFont(ofSize: 10),
                color: .gray
            )
            label.frame = CGRect(x: 0, y: y - 8, width: leftPadding - 6, height: 16)
            label.textAlignment = .right
            addSubview(label)
        }
        
        // X-axis month labels
        let stepX = chartWidth / CGFloat(cycleRecords.count - 1)
        for (i, record) in cycleRecords.enumerated() {
            let x = chartOriginX + CGFloat(i) * stepX
            let label = makeLabel(
                text: record.shortLabel,
                font: .systemFont(ofSize: 11),
                color: .gray
            )
            label.frame = CGRect(x: x - 20, y: rect.height - bottomPadding + 6, width: 40, height: 16)
            label.textAlignment = .center
            addSubview(label)
        }
    }
    
    private func makeLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        return label
    }
}

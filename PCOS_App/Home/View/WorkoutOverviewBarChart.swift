//
//  WorkoutProgressBarChart.swift
//  PCOS_App
//
//  Created for workout visualization
//

import UIKit

class WorkoutOverviewBarChart: UIView {
    
    // MARK: - Data Model
    struct SegmentData {
        let name: String
        let value: Int
        let color: UIColor
    }
    
    // MARK: - UI Components
    private let containerView = UIView()
    private var segments: [SegmentData] = []
    private var total: Int = 0
    
    private let barHeight: CGFloat = 45
    private let cornerRadius: CGFloat = 10
    
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
        backgroundColor = .clear
        
        // Container for the bar
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = cornerRadius
        containerView.clipsToBounds = true
        
        addSubview(containerView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: barHeight),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with segmentData: [SegmentData]) {
        self.segments = segmentData
        self.total = segmentData.reduce(0) { $0 + $1.value }
        
        // Clear existing views
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        guard total > 0 else { return }
        
        // Create segments with proper positioning
        var previousSegmentView: UIView?
        
        for (index, segment) in segments.enumerated() {
            let percentage = CGFloat(segment.value) / CGFloat(total)
            
            // Create segment view
            let segmentView = UIView()
            segmentView.backgroundColor = segment.color
            segmentView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(segmentView)
            
            if index == 0 {
                // First segment
                NSLayoutConstraint.activate([
                    segmentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    segmentView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    segmentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                    segmentView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: percentage)
                ])
                
                segmentView.layer.cornerRadius = cornerRadius
                segmentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else {
                // Subsequent segments
                NSLayoutConstraint.activate([
                    segmentView.leadingAnchor.constraint(equalTo: previousSegmentView!.trailingAnchor),
                    segmentView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    segmentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                    segmentView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: percentage)
                ])
                
                // Round corners for last segment
                if index == segments.count - 1 {
                    segmentView.layer.cornerRadius = cornerRadius
                    segmentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                }
            }
            
            previousSegmentView = segmentView
        }
    }
}

// MARK: - Complete Card View
class WorkoutProgressBarCardView: UIView {
    
    private let progressBar = WorkoutOverviewBarChart()
    
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
        
        // Progress bar
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(progressBar)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    // MARK: - Configuration
    func configure(with segments: [WorkoutOverviewBarChart.SegmentData]) {
        progressBar.configure(with: segments)
    }
}

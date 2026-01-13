//
//  InsulinSummaryCardView.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class InsulinSummaryCardView: UIView {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Today's Insulin Response"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    // High sugar row
    private let highEmojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "●"
        label.textColor = UIColor(hex: "#B24F57")
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    private let highTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "High sugar foods"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let highCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3 meals"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(hex: "#B24F57")
        return label
    }()
    
    private let highDotsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Moderate sugar row
    private let moderateEmojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "●"
        label.textColor = UIColor(hex: "#D98FAA")
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    private let moderateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Moderate sugar foods"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let moderateCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2 meals"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(hex: "#D98FAA")
        return label
    }()
    
    private let moderateDotsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Low sugar row
    private let lowEmojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "●"
        label.textColor = UIColor(hex: "#F2B6C6")
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    private let lowTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Low sugar foods"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let lowCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "5 meals"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(hex: "#F2B6C6")
        return label
    }()
    
    private let lowDotsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
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
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        
        // Add high sugar row
        containerView.addSubview(highEmojiLabel)
        containerView.addSubview(highTitleLabel)
        containerView.addSubview(highCountLabel)
        containerView.addSubview(highDotsView)
        
        // Add moderate sugar row
        containerView.addSubview(moderateEmojiLabel)
        containerView.addSubview(moderateTitleLabel)
        containerView.addSubview(moderateCountLabel)
        containerView.addSubview(moderateDotsView)
        
        // Add low sugar row
        containerView.addSubview(lowEmojiLabel)
        containerView.addSubview(lowTitleLabel)
        containerView.addSubview(lowCountLabel)
        containerView.addSubview(lowDotsView)
        
        setupConstraints()
        
        // Create initial dots
        createDots(in: highDotsView, count: 3, color: UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0))
        createDots(in: moderateDotsView, count: 2, color: UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0))
        createDots(in: lowDotsView, count: 5, color: UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View - fills the entire view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // HIGH SUGAR ROW
            // Emoji
            highEmojiLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            highEmojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            highEmojiLabel.widthAnchor.constraint(equalToConstant: 32),
            
            // Title
            highTitleLabel.topAnchor.constraint(equalTo: highEmojiLabel.topAnchor),
            highTitleLabel.leadingAnchor.constraint(equalTo: highEmojiLabel.trailingAnchor, constant: 12),
            
            // Count
            highCountLabel.topAnchor.constraint(equalTo: highTitleLabel.bottomAnchor, constant: 2),
            highCountLabel.leadingAnchor.constraint(equalTo: highTitleLabel.leadingAnchor),
            
            // Dots
            highDotsView.centerYAnchor.constraint(equalTo: highEmojiLabel.centerYAnchor),
            highDotsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            highDotsView.heightAnchor.constraint(equalToConstant: 8),
            highDotsView.widthAnchor.constraint(equalToConstant: 60),
            
            // MODERATE SUGAR ROW
            // Emoji
            moderateEmojiLabel.topAnchor.constraint(equalTo: highCountLabel.bottomAnchor, constant: 20),
            moderateEmojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            moderateEmojiLabel.widthAnchor.constraint(equalToConstant: 32),
            
            // Title
            moderateTitleLabel.topAnchor.constraint(equalTo: moderateEmojiLabel.topAnchor),
            moderateTitleLabel.leadingAnchor.constraint(equalTo: moderateEmojiLabel.trailingAnchor, constant: 12),
            
            // Count
            moderateCountLabel.topAnchor.constraint(equalTo: moderateTitleLabel.bottomAnchor, constant: 2),
            moderateCountLabel.leadingAnchor.constraint(equalTo: moderateTitleLabel.leadingAnchor),
            
            // Dots
            moderateDotsView.centerYAnchor.constraint(equalTo: moderateEmojiLabel.centerYAnchor),
            moderateDotsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            moderateDotsView.heightAnchor.constraint(equalToConstant: 8),
            moderateDotsView.widthAnchor.constraint(equalToConstant: 60),
            
            // LOW SUGAR ROW
            // Emoji
            lowEmojiLabel.topAnchor.constraint(equalTo: moderateCountLabel.bottomAnchor, constant: 20),
            lowEmojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            lowEmojiLabel.widthAnchor.constraint(equalToConstant: 32),
            
            // Title
            lowTitleLabel.topAnchor.constraint(equalTo: lowEmojiLabel.topAnchor),
            lowTitleLabel.leadingAnchor.constraint(equalTo: lowEmojiLabel.trailingAnchor, constant: 12),
            
            // Count
            lowCountLabel.topAnchor.constraint(equalTo: lowTitleLabel.bottomAnchor, constant: 2),
            lowCountLabel.leadingAnchor.constraint(equalTo: lowTitleLabel.leadingAnchor),
            lowCountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            // Dots
            lowDotsView.centerYAnchor.constraint(equalTo: lowEmojiLabel.centerYAnchor),
            lowDotsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            lowDotsView.heightAnchor.constraint(equalToConstant: 8),
            lowDotsView.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Helper Methods
    private func createDots(in container: UIView, count: Int, color: UIColor) {
        // Clear existing dots
        container.subviews.forEach { $0.removeFromSuperview() }
        
        let maxDots = 5
        let dotsToShow = min(count, maxDots)
        let dotSize: CGFloat = 8
        let spacing: CGFloat = 4
        
        for i in 0..<dotsToShow {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = color
            dot.layer.cornerRadius = dotSize / 2
            container.addSubview(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                dot.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: CGFloat(i) * (dotSize + spacing))
            ])
        }
    }
    
    // MARK: - Configuration
    func configure(high: Int, moderate: Int, low: Int) {
        highCountLabel.text = "\(high) meals"
        moderateCountLabel.text = "\(moderate) meals"
        lowCountLabel.text = "\(low) meals"
        
        createDots(in: highDotsView, count: high, color: UIColor(hex: "#B24F57"))
        createDots(in: moderateDotsView, count: moderate, color: UIColor(hex: "#D98FAA"))
        createDots(in: lowDotsView, count: low, color: UIColor(hex: "#F2B6C6"))
    }
}


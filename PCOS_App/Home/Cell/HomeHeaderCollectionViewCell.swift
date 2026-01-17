//
//  HomeHeaderCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

protocol HomeHeaderCollectionViewCellDelegate: AnyObject {
    func homeHeaderCellDidTapLogPeriod(_ cell: HomeHeaderCollectionViewCell)
}

class HomeHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var gradientOverlayView: UIView!
    
    @IBOutlet weak var quoteLabel: UILabel!
    
    @IBOutlet weak var cycleDayLabel: UILabel!
    @IBOutlet weak var logPeriodButton: UIButton!
    
    weak var delegate: HomeHeaderCollectionViewCellDelegate?
    
    private let gradientLayer = CAGradientLayer()
    
    private var periodDates: [Date] = []
    
        override func awakeFromNib() {
            super.awakeFromNib()
            setup()
            setupMultiStopGradient()
            //load data initially
            loadSavedPeriodData()
        }
    
    //called everytime the cell is baout to be displayed
    override func prepareForReuse() {
            super.prepareForReuse()
            //reload period data when cell is reused to ensure latest data is shown
            loadSavedPeriodData()
        }

        private func setup() {
            headerImageView.image = UIImage(named: "home_image_trial_2")
            headerImageView.contentMode = .scaleToFill
            headerImageView.clipsToBounds = true
            
            logPeriodButton.layer.cornerRadius = logPeriodButton.frame.height / 2
            logPeriodButton.tintColor = UIColor(hex: "#FE7A96")
            logPeriodButton.addTarget(self, action: #selector(logPeriodButtonTapped), for: .touchUpInside)
        }
    
    @objc private func logPeriodButtonTapped() {
        delegate?.homeHeaderCellDidTapLogPeriod(self)
    }
    
    private func setupMultiStopGradient() {
            // The color you want to blend into
            let blendColor = UIColor(hex: "#FCEEED")
        gradientOverlayView.backgroundColor = .clear
            
            gradientLayer.colors = [
                UIColor.clear.cgColor,                // 0% Top: Pure image
                UIColor.clear.cgColor,                // 70% Middle: Still pure image
                blendColor.withAlphaComponent(0.4).cgColor, // 85% Start: Soft transition
                blendColor.withAlphaComponent(0.7).cgColor,// 95%: Solid color
                blendColor.cgColor                    // 100% Bottom: Solid color
            ]
            
            // top 75% of your image crystal clear
            gradientLayer.locations = [0.0, 0.70, 0.85, 0.95, 1.0]
            
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
            if gradientLayer.superlayer == nil {
                headerImageView.layer.addSublayer(gradientLayer)
            }
        }
    
    private func loadSavedPeriodData() {
        // Load saved dates from UserDefaults
                if let timestamps = UserDefaults.standard.array(forKey: "SavedPeriodDates") as? [TimeInterval] {
                    periodDates = timestamps.map { Date(timeIntervalSince1970: $0) }.sorted()
                    print("HomeHeaderCell: Loaded \(periodDates.count) saved period dates")
                } else {
                    //HomeHeaderCell: No saved period dates found
                    periodDates = []
                }

            
            updateCycleDayLabel()
        }
    
    private func updateCycleDayLabel() {
        let cycleDay = calculateCurrentCycleDay()
                if cycleDay > 0 {
                    cycleDayLabel.text = "Day \(cycleDay) of Cycle"
                    print("HomeHeaderCell: Displaying cycle day \(cycleDay)")
                } else {
                    cycleDayLabel.text = "Log Period"
                    print("HomeHeaderCell: No cycle data, showing 'Log Period'")
                }
        }
    
    //SKS: I ahve not added calculation of cycle day if it happens before the month start, this is for each month, because that part like if it becomes 40 days and all we have to calculate according to the users cycle length
    private func calculateCurrentCycleDay() -> Int {
        guard !periodDates.isEmpty else {
                return 0
            }
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Get current month's start
            guard let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
                return 0
            }
            
            // Filter dates in current month
            let currentMonthDates = periodDates.filter { date in
                calendar.isDate(date, equalTo: currentMonthStart, toGranularity: .month)
            }
            
            // Find the earliest (first) date in current month
            guard let firstPeriodDate = currentMonthDates.min() else {
                return 0
            }
            
            // Calculate days between first period date and today
            let components = calendar.dateComponents([.day], from: firstPeriodDate, to: today)
            let daysDifference = components.day ?? 0
            
            // Cycle day is daysDifference + 1 (since first day is day 1, not day 0)
            let cycleDay = daysDifference + 1
            
            // Debug log
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            print("First period date this month: \(formatter.string(from: firstPeriodDate))")
            print("Today: \(formatter.string(from: today))")
            print("Calculated cycle day: \(cycleDay)")
            
            return cycleDay
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer.frame = headerImageView.bounds

        }
    
    // PUBLIC METHOD: Call this to refresh the cycle day label from outside
        func refreshCycleDay() {
            loadSavedPeriodData()
        }


}

//
//  ProteinViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class ProteinViewController: UIViewController {
    
    @IBOutlet weak var proteinChartContainer: ProteinIntakeChartView!

    @IBOutlet weak var View2_1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View1: UIView!
    
    var recommendation: Recommendation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let rec = recommendation {print("Workout recommendation: \(rec.title)")}
        
        View1.layer.cornerRadius = 30
        View1.clipsToBounds = true
        
        View2.layer.cornerRadius = 30
        View2.clipsToBounds = true
        
        View2_1.layer.cornerRadius = 20
        View2_1.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        setupProteinChart()
    }
    private func setupProteinChart() {
        // Clear container
        proteinChartContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Create chart
        let chartCard = ProteinIntakeChartCardView()
        chartCard.translatesAutoresizingMaskIntoConstraints = false
        proteinChartContainer.addSubview(chartCard)
        
        // Pin to edges
        NSLayoutConstraint.activate([
            chartCard.topAnchor.constraint(equalTo: proteinChartContainer.topAnchor),
            chartCard.leadingAnchor.constraint(equalTo: proteinChartContainer.leadingAnchor),
            chartCard.trailingAnchor.constraint(equalTo: proteinChartContainer.trailingAnchor),
            chartCard.bottomAnchor.constraint(equalTo: proteinChartContainer.bottomAnchor)
        ])
        
        // Configure with your data
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var data: [ProteinIntakeChartView.DataPoint] = []
        
        // Last week (higher intake)
        let lastWeek: [CGFloat] = [65, 72, 78, 70, 68, 75, 80]
        for (i, day) in weekdays.enumerated() {
            data.append(ProteinIntakeChartView.DataPoint(day: day, value: lastWeek[i], type: .lastWeek))
        }
        
        // This week (lower intake)
        let thisWeek: [CGFloat] = [45, 50, 42, 55, 48, 52, 58]
        for (i, day) in weekdays.enumerated() {
            data.append(ProteinIntakeChartView.DataPoint(day: day, value: thisWeek[i], type: .thisWeek))
        }
        
        chartCard.configure(with: data)
    }

}

//
//  WorkoutPushViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class WorkoutPushViewController: UIViewController {

    @IBOutlet weak var WorkoutDonutChart: WorkoutPieChart!
    override func viewDidLoad() {
        super.viewDidLoad()

        addWorkoutChart()
    }
    
    private func addWorkoutChart() {
            // Clear container
            WorkoutDonutChart.subviews.forEach { $0.removeFromSuperview() }
            
            // Create chart
            let chartView = WorkoutPieChartView()
            chartView.translatesAutoresizingMaskIntoConstraints = false
            WorkoutDonutChart.addSubview(chartView)
            
            
            
            // Configure
            let workoutData: [WorkoutPieChart.WorkoutData] = [
                WorkoutPieChart.WorkoutData(name: "Cardio", value: 5, color: .systemPink),
                WorkoutPieChart.WorkoutData(name: "Strength", value: 2, color: .systemBlue),
                WorkoutPieChart.WorkoutData(name: "Yoga", value: 1, color: .systemPurple)
            ]
            
            chartView.configure(with: workoutData)
        }

    

}

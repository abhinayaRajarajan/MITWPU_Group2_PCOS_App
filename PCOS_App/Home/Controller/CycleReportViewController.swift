//
//  CycleReportViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class CycleReportViewController: UIViewController {
    
    
    @IBOutlet weak var NextCycleCard: UIView!
    @IBOutlet weak var warningNextCycleView: UIView!
    @IBOutlet weak var CycleOverview: UIView!
    @IBOutlet weak var cycleLengthCard: UIView!
    @IBOutlet weak var periodLengthCard: UIView!
    @IBOutlet weak var cycleRegularityCard: UIView!
    
    @IBOutlet weak var periodCycleChartView: PeriodCycleChartView!
    
    @IBOutlet weak var OvulationCard: UIView!
    @IBOutlet weak var ovulationWarningCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cycle Patterns"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        NextCycleCard.layer.cornerRadius = 20
        warningNextCycleView.layer.cornerRadius = 10
        
        warningNextCycleView.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 0.1)
        ovulationWarningCard.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 0.1)
        
        CycleOverview.layer.cornerRadius = 20
        cycleLengthCard.layer.cornerRadius = 20
        periodLengthCard.layer.cornerRadius = 20
        
        //cycleRegularityCard.layer.cornerRadius = 20
        
        OvulationCard.layer.cornerRadius = 20
        ovulationWarningCard.layer.cornerRadius = 10
        
        setupPeriodCycleChart()
    }
    
    
    private func setupPeriodCycleChart() {
        let sampleData: [CycleData] = [
            CycleData(month: "Jan\n18", cycleLength: 28, periodLength: 5),
            CycleData(month: "Dec\n16", cycleLength: 29, periodLength: 5),
            CycleData(month: "Nov\n14", cycleLength: 24, periodLength: 5),
            CycleData(month: "Oct\n7", cycleLength: 26, periodLength: 5),
            CycleData(month: "Sept\n3", cycleLength: 30, periodLength: 5),
            CycleData(month: "Aug\n2", cycleLength: 30, periodLength: 5)
        ]
        
        periodCycleChartView.configure(with: sampleData)
    }
}

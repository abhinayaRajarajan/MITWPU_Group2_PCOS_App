//
//  CycleReportViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

/*calculating cycle consistency with standard deviation
 Standard Deviation (Best)

 This is the most “scientific” way.

 Step 1: Calculate average

 Mean = (30+26+24+29+28)/5 = 27.4

 Step 2: Calculate standard deviation (SD)

 Let’s say SD comes out to: 2.3 days

 Then classify it like this:
 SD (days)    Consistency label
 0–2    Very Stable
 2–4    Stable
 4–7    Somewhat Irregular
 7+    Irregular

 So if SD = 2.3 → Stable
 
 Cycle Consistency: Stable

 Variation: ±3 days
 Within normal range: 4/5 cycles
 
 *PCOS-friendly consistency logic

 Since PCOS users may have long cycles, consistency should NOT depend on “normal 21–35” only.

 So separate into:

 1) Consistency (variation-based)

 Stable vs irregular

 2) Cycle length category (average-based)

 Short
 Typical
 Long

This avoids shaming users whose cycles are long but consistent.
 */
import UIKit

class CycleReportViewController: UIViewController {
    
    
    @IBOutlet weak var NextCycleCard: UIView!
    //@IBOutlet weak var warningNextCycleView: UIView!
    @IBOutlet weak var CycleOverview: UIView!
    
    //@IBOutlet weak var cycleRegularityCard: UIView!
    
    @IBOutlet weak var periodCycleChartView: PeriodCycleChartView!
    
   
    //@IBOutlet weak var ovulationWarningCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cycle Patterns"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        NextCycleCard.layer.cornerRadius = 20
        //warningNextCycleView.layer.cornerRadius = 10
        
        
        CycleOverview.layer.cornerRadius = 20
        
        
        
        setupPeriodCycleChart()
    }
    
    
    private func setupPeriodCycleChart() {
        
            // Use shared data store — single source of truth
            let store = CycleDataStore.shared
            
            // Bar chart — last 6 cycles
            periodCycleChartView.configure(with: store.barChartData(count: 6))
      
    }
}

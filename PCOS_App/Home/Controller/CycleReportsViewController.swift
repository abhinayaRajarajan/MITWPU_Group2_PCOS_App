//
//  CycleReportsViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class CycleReportsViewController: UIViewController {

    @IBOutlet weak var cyclesView: UIView!
    @IBOutlet weak var periodDaysCard: UIView!
    @IBOutlet weak var cycleDaysCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyclesView.layer.cornerRadius = 10
        cyclesView.layer.masksToBounds = true
        
        periodDaysCard.layer.cornerRadius = 10
        periodDaysCard.layer.masksToBounds = true
        
        cycleDaysCard.layer.cornerRadius = 10
        cycleDaysCard.layer.masksToBounds = true
        
//        view.backgroundColor = UIColor(
//            red: 211/255,
//            green: 211/255,
//            blue: 255/255,
//            alpha: 1
//        )

    }
    

}

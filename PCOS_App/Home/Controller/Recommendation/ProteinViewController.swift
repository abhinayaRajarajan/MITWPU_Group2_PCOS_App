//
//  ProteinViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class ProteinViewController: UIViewController {

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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

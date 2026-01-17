//
//  UserGoalViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class UserGoalViewController: UIViewController {

    @IBOutlet weak var cycleRegularityCard: UIView!
    @IBOutlet weak var weightManagementCard: UIView!
    @IBOutlet weak var acneHairCard: UIView!
    @IBOutlet weak var energyLevelCard: UIView!
    
    private var selectedView: UIView?
    private var selectedGoalType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cycleRegularityCard.layer.cornerRadius = 20
        weightManagementCard.layer.cornerRadius = 20
        acneHairCard.layer.cornerRadius = 20
        energyLevelCard.layer.cornerRadius = 20
        
        addTapGesture(to: cycleRegularityCard, goalType: "Regular Cycles")
        addTapGesture(to: weightManagementCard, goalType: "Manage Weight")
        addTapGesture(to: acneHairCard, goalType: "Acne Hair Management")
        addTapGesture(to: energyLevelCard, goalType: "Energy Levels")
    }
    
    private func addTapGesture(to view: UIView, goalType: String) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
            view.isUserInteractionEnabled = true
            view.tag = getTag(for: goalType)
            view.addGestureRecognizer(tapGesture)
        }
    
    private func getTag(for goalType: String) -> Int {
    switch goalType {
    case "Regular Cycles": return 1
    case "Manage Weight": return 2
    case "Acne Hair Management": return 3
    case "Energy Levels": return 4
    default: return 0
    }
        }
    
    private func getGoalType(from tag: Int) -> String {
            switch tag {
            case 1: return "Regular Cycles"
            case 2: return "Manage Weight"
            case 3: return "Acne Hair Management"
            case 4: return "Energy Levels"
            default: return ""
            }
        }
    @objc private func viewTapped(_ gesture: UITapGestureRecognizer) {
            guard let tappedView = gesture.view else { return }
            
            // Deselect previous view
            if let previousView = selectedView {
                previousView.layer.borderWidth = 0
                previousView.backgroundColor = UIColor(red: 0.95, green: 0.85, blue: 0.90, alpha: 1.0)
            }
            
            // Select new view
            selectedView = tappedView
            selectedGoalType = getGoalType(from: tappedView.tag)
            
            // Highlight selected view
            tappedView.layer.borderWidth = 3
            tappedView.layer.borderColor = UIColor.systemBlue.cgColor
            tappedView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let dietType = selectedGoalType {
                    print("Selected goal type: \(dietType)")
                    
                    // Save to UserDefaults
                    UserDefaults.standard.set(dietType, forKey: "userGoalType")
                    
                    // Navigate to next screen or show alert
                    // performSegue(withIdentifier: "toNextScreen", sender: nil)
                } else {
                    print("No goal type selected")
                    
                    // Show alert to user
                    let alert = UIAlertController(title: "Selection Required",
                                                message: "Please select a goal",
                                                preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
    }
    

}

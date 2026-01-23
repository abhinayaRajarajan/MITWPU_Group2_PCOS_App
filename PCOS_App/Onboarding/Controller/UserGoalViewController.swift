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
        
        addTapGesture(to: cycleRegularityCard, goalType: "Improve cycle regularity")
        addTapGesture(to: weightManagementCard, goalType: "Manage weight comfortably")
        addTapGesture(to: acneHairCard, goalType: "Reduce acne/hair concerns")
        addTapGesture(to: energyLevelCard, goalType: "Boost daily energy levels")
    }
    
    private func addTapGesture(to view: UIView, goalType: String) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.isUserInteractionEnabled = true
        view.tag = getTag(for: goalType)
        view.addGestureRecognizer(tapGesture)
    }
    
    private func getGoalType(from tag: Int) -> String {
        switch tag {
        case 1: return "Improve cycle regularity"  // Changed from "Regular Cycles"
        case 2: return "Manage weight comfortably"  // Changed from "Manage Weight"
        case 3: return "Reduce acne/hair concerns"  // Changed from "Acne Hair Management"
        case 4: return "Boost daily energy levels"  // Changed from "Energy Levels"
        default: return ""
        }
    }

    private func getTag(for goalType: String) -> Int {
        switch goalType {
        case "Improve cycle regularity": return 1
        case "Manage weight comfortably": return 2
        case "Reduce acne/hair concerns": return 3
        case "Boost daily energy levels": return 4
        default: return 0
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
        // Check if a goal was selected
        guard let goalType = selectedGoalType else {
            // Show alert to user
            let alert = UIAlertController(title: "Selection Required",
                                          message: "Please select a goal",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return // Exit early if no selection
        }
        
        // Save selected goal to UserDefaults
        UserDefaults.standard.set(goalType, forKey: "userGoalType")
        
        // Now gather ALL onboarding data from UserDefaults
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        let height = UserDefaults.standard.integer(forKey: "userHeight")
        let weight = UserDefaults.standard.integer(forKey: "userWeight")
        let dob = UserDefaults.standard.object(forKey: "userDOB") as? Date ?? Date()
        let dietType = UserDefaults.standard.string(forKey: "userDietType") ?? "Not sure yet"
        let workoutType = UserDefaults.standard.string(forKey: "userWorkoutType") ?? "Mostly sedentary"
        // Get the goal we just saved
        let finalGoalType = UserDefaults.standard.string(forKey: "userGoalType") ?? "Improve cycle regularity"
        
        // Create complete profile with all onboarding data
        let profile = ProfileModel(
            name: name,
            dob: dob,
            height: height,
            weight: weight,
            dietType: dietType,
            workoutType: workoutType,
            goalType: finalGoalType
        )
        
        // Save to ProfileService
        ProfileService.shared.setProfile(to: profile)
        print("Complete profile saved!")
        
        // Clear temporary onboarding data
        //clearOnboardingData()
        
        if let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = tabBarVC
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
        
//        func clearOnboardingData() {
//            UserDefaults.standard.removeObject(forKey: "userName")
//            UserDefaults.standard.removeObject(forKey: "userHeight")
//            UserDefaults.standard.removeObject(forKey: "userWeight")
//            UserDefaults.standard.removeObject(forKey: "userDOB")
//            UserDefaults.standard.removeObject(forKey: "userDietType")
//            UserDefaults.standard.removeObject(forKey: "userWorkoutType")
//            UserDefaults.standard.removeObject(forKey: "userGoalType")
//            UserDefaults.standard.removeObject(forKey: "heightIsMetric")
//            
//            print("🧹 Onboarding data cleared")
//        }
        
        
    }
}


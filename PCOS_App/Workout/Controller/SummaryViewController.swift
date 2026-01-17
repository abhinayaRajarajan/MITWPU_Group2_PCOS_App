//
//  SummaryViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class SummaryViewController: UIViewController {
    
    
    var completedWorkout: CompletedWorkout!
    
    
    @IBOutlet weak var containerView: UIView!
    // Goals (you can fetch these from user settings)
    let caloriesGoal = 600.0
    let durationGoalSeconds = 120 * 60  // 2 hours
    
    @IBOutlet weak var caloriesValueLabel: UILabel!
    @IBOutlet weak var caloriesGoalLabel: UILabel!
    
    @IBOutlet weak var exercisesDoneLabel: UILabel!
    
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var durationGoalLabel: UILabel!
    
    // @IBOutlet weak var trophyImageView: UIImageView!
    
    @IBOutlet weak var caloriesCard: UIView!
    @IBOutlet weak var exercisesCard: UIView!
    @IBOutlet weak var durationCard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //modalPresentationStyle = .overCurrentContext
        view.backgroundColor = UIColor(hex: "#FCEEED")
        
        navigationItem.hidesBackButton = true
        
        //addDimmedBackground()
        
        // addOverlayBackground()
        
        setupUI()
        applyCardStyling()
        showConfetti()
    }
    
    
    //    private func addOverlayBackground() {
    //
    //        // Dim
    //        let dimView = UIView(frame: view.bounds)
    //        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
    //        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    //        view.addSubview(dimView)
    //
    //        // Blur (THIS blurs StartRoutine, not Summary)
    //        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    //        blur.frame = view.bounds
    //        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    //        view.insertSubview(blur, aboveSubview: dimView)
    //
    //        // Card above blur
    //        view.bringSubviewToFront(containerView)
    //    }
    
    func setupUI() {
        containerView.layer.cornerRadius=24
        
        // ---- DURATION ----
        let totalSeconds = completedWorkout.durationSeconds
        durationValueLabel.text = formatDuration(totalSeconds)
        //durationGoalLabel.text = "/ " + formatDuration(durationGoalSeconds)
        
        // ---- CALORIES ----
        let calories = Double(totalSeconds) * 0.18
        caloriesValueLabel.text = String(format: "%.0f", calories)
        //      caloriesGoalLabel.text = "/\(Int(caloriesGoal))"
        
        // ---- EXERCISES DONE ----
        let completedExercises = completedWorkout.exercises.filter {
            $0.sets.allSatisfy { $0.completionState == .completed }
        }.count
        
        exercisesDoneLabel.text = "\(completedExercises)"
    }
    
    func applyCardStyling() {
        let cards = [caloriesCard, exercisesCard, durationCard]
        cards.forEach { card in
            card?.layer.cornerRadius = 20
            //card?.layer.shadowColor = UIColor.black.cgColor
            //card?.layer.shadowOpacity = 0.08
            //card?.layer.shadowOffset = CGSize(width: 0, height: 3)
            //card?.layer.shadowRadius = 6
            card?.backgroundColor = .systemBackground
            card?.layer.masksToBounds = false
        }
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        
        if hrs > 0 {
            return "\(hrs)h \(mins)"
        } else {
            return "\(mins)"
        }
    }
    
    
    
    func showConfetti() {
        let confettiLayer = CAEmitterLayer()
        
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.size.width, height: 1)
        
        // Vibrant confetti colors
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),    // Gold
            UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0),    // Hot Pink
            UIColor(red: 0.5, green: 0.2, blue: 0.9, alpha: 1.0),    // Purple
            UIColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1.0),    // Green
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),    // Orange
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),    // Blue
            UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0),    // Red
            UIColor(red: 0.9, green: 0.9, blue: 0.2, alpha: 1.0)     // Yellow
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            // Create multiple particles per color for better effect
            for _ in 0..<2 {
                let cell = CAEmitterCell()
                
                // Emission settings
                cell.birthRate = 6
                cell.lifetime = 10.0
                cell.lifetimeRange = 3
                
                // Velocity and direction
                cell.velocity = CGFloat.random(in: 200...350)
                cell.velocityRange = 100
                cell.emissionLongitude = .pi  // Downward
                cell.emissionRange = .pi / 3  // Spread angle
                
                // Rotation
                cell.spin = CGFloat.random(in: 2...5)
                cell.spinRange = 3
                
                // Size
                cell.scale = CGFloat.random(in: 0.3...0.6)
                cell.scaleRange = 0.2
                cell.scaleSpeed = -0.05  // Gradually shrink
                
                // Physics
                cell.yAcceleration = 150  // Gravity effect
                cell.xAcceleration = CGFloat.random(in: -20...20)  // Slight drift
                
                // Appearance
                cell.alphaSpeed = -0.1  // Fade out gradually
                cell.color = color.cgColor
                
                // Random shape for variety
                let shapes = ["circle", "square", "triangle"]
                let randomShape = shapes.randomElement() ?? "circle"
                cell.contents = confettiImage(shape: randomShape, color: color)?.cgImage
                
                cells.append(cell)
            }
            
        }
        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        
        // Stop emitting new particles after 2 seconds, but let existing ones finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            confettiLayer.birthRate = 0
        }
        
        // Remove layer completely after animation finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            confettiLayer.removeFromSuperlayer()
        }
    }
    func confettiImage(shape: String, color: UIColor) -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            
            switch shape {
            case "square":
                let rect = CGRect(x: 2, y: 2, width: 16, height: 16)
                context.cgContext.fill(rect)
                
            case "triangle":
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: 2))
                path.addLine(to: CGPoint(x: 2, y: size.height - 2))
                path.addLine(to: CGPoint(x: size.width - 2, y: size.height - 2))
                path.close()
                path.fill()
                
            case "circle":
                let rect = CGRect(x: 2, y: 2, width: 16, height: 16)
                context.cgContext.fillEllipse(in: rect)
                
            default:
                break
            }
        }
    }
        @IBAction func doneButtonTapped(_ sender: UIButton) {
            //NAVIGATION TO HOME VC-> but it comes embedded in a navigation bar,no tab bar
//            let homeVC = UIStoryboard(name: "Workout", bundle: nil)
//                .instantiateViewController(withIdentifier: "WorkoutHome") as! WorkoutViewController
//            navigationController?.pushViewController(homeVC, animated: true)
            
            //just uncomment to navigate to routine preview vc
            
            view.window?.rootViewController?.dismiss(animated: true)
            //dismiss(animated: true)
            
            
        }
        
    }

//
//  RoutineExerciseTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 01/12/25.
//

import UIKit
class RoutineExerciseTableViewCell: UITableViewCell {
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var muscleTypeLabel: UILabel!
    @IBOutlet weak var exerciseImageView: UIImageView!
    
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var restTimerLabel: UILabel!
    @IBOutlet weak var durationTextField: UITextField! // for cardio only
    
    // StackViews (recommended)
    @IBOutlet weak var strengthStackView: UIStackView!
    @IBOutlet weak var cardioStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        exerciseImageView.contentMode = .scaleAspectFill
                exerciseImageView.clipsToBounds = true
                exerciseImageView.layer.cornerRadius = 8
                
                // Configure labels
                exerciseNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                exerciseNameLabel.textColor = .label
                
                muscleTypeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                muscleTypeLabel.textColor = .secondaryLabel
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
//    func configure(with model: RoutineExercise) {
//            // Set exercise name
//            exerciseNameLabel.text = model.exercise.name
//
//            // Set muscle type
//            muscleTypeLabel.text = model.exercise.muscleGroup.displayName
//
//        setsTextField.text = "\(model.numberOfSets)"
//            repsTextField.text = "\(model.reps)"
//            weightTextField.text = "\(model.weightKg)"
//
//            // Set image with fallback
//            if let imageName = model.exercise.image, !imageName.isEmpty {
//                exerciseImageView.image = UIImage(named: imageName)
//            } else {
//                // Use SF Symbol as placeholder
//                exerciseImageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
//                exerciseImageView.tintColor = .systemGray
//            }
//        }
    // Optional: Reset cell when reused
        override func prepareForReuse() {
            super.prepareForReuse()
            exerciseImageView.image = nil
            exerciseNameLabel.text = nil
            muscleTypeLabel.text = nil
        }
    
    func configure(with model: RoutineExercise) {
        exerciseNameLabel.text = model.exercise.name
        muscleTypeLabel.text = model.exercise.muscleGroup.displayName
        
        // Load image
        if let img = model.exercise.image {
            exerciseImageView.image = UIImage(named: img)
        } else {
            exerciseImageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
        }
        
        // MARK: Cardio vs Strength UI
        if model.exercise.isCardio {
            // Show only duration
            strengthStackView.isHidden = true
            //restTimerLabel.isHidden = true
            cardioStackView.isHidden = false
            
            durationTextField.text = "\(model.durationSeconds ?? 10)"
            
        } else {
            // Show strength fields
            strengthStackView.isHidden = false
            //restTimerLabel.isHidden = false
            cardioStackView.isHidden = true
            
            setsTextField.text = "\(model.numberOfSets)"
            repsTextField.text = "\(model.reps)"
            weightTextField.text = "\(model.weightKg)"
            
            let rest = model.restTimerSeconds ?? 0
            //restTimerLabel.text = "Rest Timer: \(rest == 0 ? "OFF" : "\(rest)s")"
        }
    }
    
}


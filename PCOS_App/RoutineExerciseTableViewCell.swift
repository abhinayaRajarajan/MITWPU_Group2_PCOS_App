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
    
    func configure(with routineExercise: RoutineExercise) {
            // Set exercise name
            exerciseNameLabel.text = routineExercise.exercise.name
            
            // Set muscle type
            muscleTypeLabel.text = routineExercise.exercise.muscleGroup.displayName
            
            // Set image with fallback
            if let imageName = routineExercise.exercise.image, !imageName.isEmpty {
                exerciseImageView.image = UIImage(named: imageName)
            } else {
                // Use SF Symbol as placeholder
                exerciseImageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
                exerciseImageView.tintColor = .systemGray
            }
        }
    // Optional: Reset cell when reused
        override func prepareForReuse() {
            super.prepareForReuse()
            exerciseImageView.image = nil
            exerciseNameLabel.text = nil
            muscleTypeLabel.text = nil
        }
    
}

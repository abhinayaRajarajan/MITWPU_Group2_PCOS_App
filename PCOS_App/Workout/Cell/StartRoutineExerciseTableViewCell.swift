//
//  StartRoutineExerciseTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class StartRoutineExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var muscleLabel: UILabel!
    @IBOutlet weak var restTimerLabel: UILabel!

    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!

    @IBOutlet weak var doneButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var onDoneTapped: ((Bool) -> Void)?


    func configure(with exercise: WorkoutExercise) {

        
        
        
        exerciseNameLabel.text = exercise.exercise.name
        muscleLabel.text = exercise.exercise.muscleGroup.displayName

        let rest = exercise.sets.first?.restTimerSeconds ?? 0
        restTimerLabel.text = "Rest Timer : \(rest) secs"

        setCountLabel.text = "\(exercise.sets.first?.setNumber ?? 1)"
        weightLabel.text = "\(exercise.sets.first?.weightKg ?? 0)"
        repsLabel.text = "\(exercise.sets.first?.reps ?? 0)"

        // Correct handling of completion state
        let isDone = exercise.sets.first?.isCompleted ?? false

        doneButton.isSelected = isDone   //  THIS WAS MISSING
        let imageName = isDone ? "checkmark.square.fill" : "square"
        doneButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()

            let newImage = sender.isSelected ? "checkmark.square.fill" : "square"
            sender.setImage(UIImage(systemName: newImage), for: .normal)

            // send the NEW state up
            onDoneTapped?(sender.isSelected)   // 0 because you're only showing 1 set per exercise for now
    }

}

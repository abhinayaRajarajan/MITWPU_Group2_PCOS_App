//
//  RoutinePreviewTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class RoutinePreviewTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var muscleLabel: UILabel!
    
    @IBOutlet weak var setCountLabel: UILabel!
    //@IBOutlet weak var weightLabel: UILabel!
    //@IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    
    var onInfoTapped: (() -> Void)?
    
    @IBOutlet weak var ExerciseProgressViewOutlet: UIProgressView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    @IBAction func InfoButtonAction(_ sender: Any) {
        onInfoTapped?()
    }
    
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
    
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        exerciseImageView.contentMode = .scaleAspectFit
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configure(with routineExercise: RoutineExercise,workoutExercise: WorkoutExercise?) {
        let exercise = routineExercise.exercise
        
        exerciseNameLabel.text = exercise.name
        muscleLabel.text = exercise.muscleGroup.displayName
        levelLabel.text = exercise.level
        setCountLabel.text = exercise.isCardio
        ? "\(routineExercise.durationSeconds ?? 0 / 60) min"
        : "\(routineExercise.numberOfSets) sets"
        
        exerciseImageView.image = UIImage(named: exercise.image ?? "exercise_placeholder")
        
        configureProgress(workoutExercise)
    }
//    private func configureProgress(_ routineExercise: RoutineExercise) {
//        ExerciseProgressViewOutlet.progress = 0.0
//    }
    private func configureProgress(_ workoutExercise: WorkoutExercise?) {

        guard let workoutExercise = workoutExercise else {
            ExerciseProgressViewOutlet.progress = 0
            return
        }

        let totalSets = workoutExercise.sets.count
        let completedSets = workoutExercise.sets.filter {
            $0.completionState == .completed
        }.count

        let progress = Float(completedSets) / Float(max(totalSets, 1))
        ExerciseProgressViewOutlet.progress = progress
        ExerciseProgressViewOutlet.setProgress(progress, animated: true)

    }

    
    
}

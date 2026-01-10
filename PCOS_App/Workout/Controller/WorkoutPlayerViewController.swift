//
//  WorkoutPlayerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class WorkoutPlayerViewController: UIViewController {

    @IBOutlet weak var WeightOutlet: UILabel!
    @IBOutlet weak var RepsOutlet: UILabel!
    @IBOutlet weak var SetNumberOutlet: UILabel!
    @IBOutlet weak var ProgressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var GifOutlet: UIImageView!
    @IBOutlet weak var SecondaryControlViewOutlet: UIView!
    @IBOutlet weak var PrimaryControlViewOutlet: UIView!
    //@IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var pauseOutlet: UIImageView!
    
    @IBOutlet weak var pauseContainer: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    private var isPaused = false
    var timer: Timer?
    var elapsedSeconds = 0
    var workoutExercise: WorkoutExercise!
    var currentSetIndex: Int = 0

    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var bottomSheetBottomConstraint: NSLayoutConstraint!//bottom constraint

    @IBOutlet weak var nextExerciseButton: UIButton!
    
    @IBOutlet weak var endWorkoutButton: UIButton!
    
    private enum SheetState {
        case collapsed
        case expanded
    }

    private var sheetState: SheetState = .collapsed

    private let collapsedOffset: CGFloat = 0
    private var expandedOffset: CGFloat {
        return bottomContainerView.bounds.height
    }
  // tweak based on your secondary height

    
    var activeWorkout: ActiveWorkout!
    var exerciseIndex: Int = 0     // which exercise in routine
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let activeWorkout = activeWorkout else {
            assertionFailure("activeWorkout not injected")
            return
        }

        self.activeWorkout = activeWorkout

        // SAFELY derive workoutExercise
        self.workoutExercise = activeWorkout.exercises[exerciseIndex]

        SecondaryControlViewOutlet.alpha = 0
        SecondaryControlViewOutlet.isUserInteractionEnabled = false
        
        pauseContainer.layer.cornerRadius = pauseContainer.frame.height / 2
        skipButton.layer.cornerRadius = skipButton.frame.height / 2
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
        
        nextExerciseButton.layer.cornerRadius = 20
        endWorkoutButton.layer.cornerRadius = 100
        
        
        setupPlayTap()
        configureUI()
        setupBottomSheet()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // CRITICAL: Reset to collapsed state when returning from rest timer
            setSheetState(.collapsed, animated: false)
            
            // Ensure primary controls are visible and interactive
            PrimaryControlViewOutlet.alpha = 1
            PrimaryControlViewOutlet.isUserInteractionEnabled = true
            
            // Resume if not paused
            if !isPaused {
                startTimer()
            }
        }
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           // Only start timer on first appearance
           if timer == nil && !isPaused {
               startTimer()
           }
       }
       
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           
           // CRITICAL: Stop timer when leaving this view
           timer?.invalidate()
           timer = nil
       }
    private func setupPlayTap() {
        pauseOutlet.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(pauseTapped)
        )

        pauseOutlet.addGestureRecognizer(tapGesture)
    }


//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        startTimer()
//    }

    private func configureUI() {
        guard let workoutExercise = workoutExercise else {
            assertionFailure("WorkoutExercise not injected before WorkoutPlayerViewController loaded")
            return
        }

        let exercise = workoutExercise.exercise
        let currentSet = workoutExercise.sets[currentSetIndex]
        
        
        title=exercise.name
        navigationController?.navigationBar.prefersLargeTitles = false
        //ExerciseNameOutlet.text = exercise.name
        RepsOutlet.text = "\(currentSet.reps)"
        //WeightOutlet.text = "\(currentSet.weightKg)"
        GifOutlet.image = exercise.gifImage
        GifOutlet.layer.cornerRadius = 20
        GifOutlet.contentMode = .scaleAspectFill

//        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        updateTimerDisplay()
        
    }

    private func setupBottomSheet() {
        // Make sure secondary view is in the hierarchy but invisible
        SecondaryControlViewOutlet.alpha = 0
        SecondaryControlViewOutlet.isUserInteractionEnabled = false
        
        // Start in collapsed state
        bottomSheetBottomConstraint.constant = collapsedOffset
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        PrimaryControlViewOutlet.addGestureRecognizer(pan)
    }
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .began:
            // Ensure secondary controls are visible during drag
            SecondaryControlViewOutlet.alpha = 1
            
        case .changed:
            // Dragging up = negative translation.y = should increase constraint
            let newOffset = bottomSheetBottomConstraint.constant - translation.y
            bottomSheetBottomConstraint.constant = clamp(newOffset)
            
            // Update secondary alpha based on drag progress
            let progress = bottomSheetBottomConstraint.constant / expandedOffset
            SecondaryControlViewOutlet.alpha = progress
            
            gesture.setTranslation(.zero, in: view)

        case .ended, .cancelled:
            // Determine final state based on velocity and position
            let currentOffset = bottomSheetBottomConstraint.constant
            let shouldExpand = velocity.y < -100 || currentOffset > expandedOffset / 2
            setSheetState(shouldExpand ? .expanded : .collapsed, animated: true)

        default:
            break
        }
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        if value < collapsedOffset {
            return collapsedOffset + (value - collapsedOffset) * 0.2
        }
        if value > expandedOffset {
            return expandedOffset + (value - expandedOffset) * 0.2
        }
        return value
    }


    private func setSheetState(_ state: SheetState, animated: Bool = true) {
        sheetState = state

        let targetOffset = (state == .expanded) ? expandedOffset : collapsedOffset

        if state == .expanded {
            bottomContainerView.bringSubviewToFront(SecondaryControlViewOutlet)
            SecondaryControlViewOutlet.isUserInteractionEnabled = true
            PrimaryControlViewOutlet.isUserInteractionEnabled = true  
        } else {
            bottomContainerView.bringSubviewToFront(PrimaryControlViewOutlet)
            SecondaryControlViewOutlet.isUserInteractionEnabled = false
            PrimaryControlViewOutlet.isUserInteractionEnabled = true
        }

        bottomSheetBottomConstraint.constant = targetOffset

        let animations = {
            self.SecondaryControlViewOutlet.alpha = (state == .expanded) ? 1 : 0
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: animations)
        } else {
            animations()
        }
    }

        
    
    
    private func setSecondaryControlsVisible(_ visible: Bool) {
        if visible {
            SecondaryControlViewOutlet.isHidden = false
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.SecondaryControlViewOutlet.alpha = visible ? 1 : 0
        } completion: { _ in
            if !visible {
                self.SecondaryControlViewOutlet.isHidden = true
            }
        }
    }
    
    @objc func pauseTapped() {
        isPaused.toggle()
            
            if isPaused {
                timer?.invalidate()
                pauseOutlet.image = UIImage(systemName: "play.fill")
                
                // EXPAND the sheet when pausing (like Apple Fitness)
                setSheetState(.expanded, animated: true)
                
            } else {
                startTimer()
                pauseOutlet.image = UIImage(systemName: "pause.fill")
                
                // COLLAPSE the sheet when resuming
                setSheetState(.collapsed, animated: true)
            }
    }
    
//    @IBAction func pauseTapped(_ sender: UIButton) {
//        isPaused.toggle()
//            
//            if isPaused {
//                timer?.invalidate()
//                pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//                
//                // EXPAND the sheet when pausing (like Apple Fitness)
//                setSheetState(.expanded, animated: true)
//                
//            } else {
//                startTimer()
//                pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//                
//                // COLLAPSE the sheet when resuming
//                setSheetState(.collapsed, animated: true)
//            }
//    }
    @IBAction func endWorkoutTapped(_ sender: UIButton) {
                print("end workout tapped ")
                self.finishWorkoutAndShowSummary()
            

            
                self.timer?.invalidate()
                self.dismiss(animated: true)
            

        

               
    }

    private func startTimer() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.elapsedSeconds += 1
                self?.updateTimerDisplay()
            }
        }
        
        private func updateTimerDisplay() {
            let hours = elapsedSeconds / 3600
            let minutes = (elapsedSeconds % 3600) / 60
            let seconds = elapsedSeconds % 60
            timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    
    
    // MARK: - Progress Helpers

    private func totalSetsInRoutine() -> Int {
        guard let activeWorkout = activeWorkout else { return 0 }
        return activeWorkout.exercises.reduce(0) { $0 + $1.sets.count }
    }


    private func completedSetsInRoutine() -> Int {
        guard let activeWorkout = activeWorkout else { return 0 }

        return activeWorkout.exercises.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.count
        }
    }


    private func updateProgressBar() {
        let completed = completedSetsInRoutine()
        let total = totalSetsInRoutine()
        
        let progress = CGFloat(completed) / CGFloat(max(total, 1))
        
        ProgressWidthConstraint.constant = progress * view.bounds.width
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func doneTapped(_ sender: UIButton) {
        completeCurrentSet(skipped: false)
    }
    private func completeCurrentSet(skipped: Bool) {
        timer?.invalidate()
        
        var exercise = activeWorkout.exercises[exerciseIndex]
        
        // MARK: Cardio logic
        if exercise.exercise.isCardio {
            let required = exercise.sets[0].durationSeconds ?? 0
            if elapsedSeconds < required && !skipped {
                return // don't allow early completion
            }
            exercise.sets[0].isCompleted = true
            activeWorkout.exercises[exerciseIndex] = exercise
            updateProgressBar()
            goToRestBeforeNext()
            return
        }
        
        // MARK: Strength logic
        // Only mark as completed if not skipped
        if !skipped {
            exercise.sets[currentSetIndex].isCompleted = true
            activeWorkout.exercises[exerciseIndex] = exercise
            updateProgressBar()
        }
        
        // Check if there are more sets in this exercise
        if currentSetIndex + 1 < exercise.sets.count {
            // Move to next set
            currentSetIndex += 1
            // Trigger rest timer before loading next set
            performSegue(withIdentifier: "RestTimeStart", sender: nil)
        } else {
            // All sets completed, move to next exercise after rest
//            moveToNextExercise()
            goToRestBeforeNext()
        }
    }
    @IBAction func skipTapped(_ sender: UIButton) {
        completeCurrentSet(skipped: true)
    }
    private func loadCurrentSet() {
        // FIXED: Skip button should skip the current set, not go to rest
                var exercise = activeWorkout.exercises[exerciseIndex]
                
                // Mark current set as completed (but skipped)
                exercise.sets[currentSetIndex].isCompleted = true
                activeWorkout.exercises[exerciseIndex] = exercise
                updateProgressBar()
                
                // Check if there are more sets
                if currentSetIndex + 1 < exercise.sets.count {
                    // Move to next set WITHOUT rest timer
                    currentSetIndex += 1
                    loadCurrentSet()
                } else {
                    // All sets done, move to next exercise
                    advanceToNextExerciseImmediately()
                }
    }
//    private func moveToNextExercise() {
//        updateProgressBar()
//        
//        performSegue(withIdentifier: "RestTimeStart", sender: nil)
//    }
    private func goToRestBeforeNext() {
        updateProgressBar()
        performSegue(withIdentifier: "RestTimeStart", sender: nil)
    }
    private func advanceToNextExerciseImmediately() {
        exerciseIndex += 1
        currentSetIndex = 0

        if exerciseIndex >= activeWorkout.exercises.count {
            finishWorkout()
            return
        }

        loadCurrentSet()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RestTimeStart" {
            guard let vc = segue.destination as? RestTimeViewController else { return }

            vc.onRestFinished = { [weak self] in
                guard let self = self else { return }

                let exercise = self.activeWorkout.exercises[self.exerciseIndex]

                if self.currentSetIndex < exercise.sets.count - 1 {
                    self.currentSetIndex += 1
                    self.loadCurrentSet()
                } else {
                    self.advanceToNextExerciseImmediately()

                }
            }

        }
    }
    private func goToNextExercise() {
        exerciseIndex += 1
        currentSetIndex = 0
        
        if exerciseIndex >= activeWorkout.exercises.count {
            finishWorkout()
            return
        }
        
        loadCurrentSet()
    }
    private func finishWorkout() {
        activeWorkout.finish()
        
        let completed = CompletedWorkout(
            routineName: activeWorkout.routine.name,
            date: Date(),
            durationSeconds: activeWorkout.durationSeconds,
            exercises: activeWorkout.exercises
        )
        
        WorkoutSessionManager.shared.completedWorkouts.append(completed)
        
        dismiss(animated: true)
    }
    private func finishWorkoutAndShowSummary() {
        timer?.invalidate()
        
     
        let elapsed = Int(Date().timeIntervalSince(activeWorkout.startTime))
        activeWorkout.durationSeconds = elapsed
        
        activeWorkout.finish()
        
        let completedWorkout = CompletedWorkout(
            routineName: activeWorkout.routine.name,
            date: Date(),
            durationSeconds: elapsed,
            exercises: activeWorkout.exercises
        )
        
        WorkoutSessionManager.shared.completedWorkouts.append(completedWorkout)
        
        
        let summaryVC = UIStoryboard(name: "Workout", bundle: nil)
            .instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
        
        summaryVC.completedWorkout = completedWorkout
        
        //navigationController?.popToRootViewController(animated: true)
            }
        
    @IBAction func skipExerciseTapped(_ sender: UIButton) {
        timer?.invalidate()

        // Mark all remaining sets as skipped
        var exercise = activeWorkout.exercises[exerciseIndex]
        for i in 0..<exercise.sets.count {
            exercise.sets[i].isCompleted = true
        }
        activeWorkout.exercises[exerciseIndex] = exercise

        updateProgressBar()

        // DIRECTLY move to next exercise (no rest)
        advanceToNextExerciseImmediately()

    }

    

   
}

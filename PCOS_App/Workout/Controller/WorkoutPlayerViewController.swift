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
   // @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    private var isPaused = false
    private var isExpanded = false
    var timer: Timer?
    var elapsedSeconds = 0
    var workoutExercise: WorkoutExercise!
    var currentSetIndex: Int = 0

    @IBOutlet weak var bottomContainerView: UIView!
    
   // @IBOutlet weak var bottomSheetHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var grabberView: UIView!

    @IBOutlet weak var nextExerciseButton: UIButton!
    
    @IBOutlet weak var endWorkoutButton: UIButton!
    
    
    @IBOutlet weak var bottomContainerBottomConstraint: NSLayoutConstraint!

    // This controls the height (collapsed vs expanded)
    @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!

    
    private let collapsedHeight: CGFloat = 170   // grabber + primary
    private let expandedHeight: CGFloat = 220    // includes secondary
    private var panGestureRecognizer: UIPanGestureRecognizer!

    
    var activeWorkout: ActiveWorkout!
    var exerciseIndex: Int = 0     // which exercise in routine
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let activeWorkout = activeWorkout else {
            assertionFailure("activeWorkout not injected")
            return
        }

        self.activeWorkout = activeWorkout

        // SAFELY derive active workoutExercise
        self.workoutExercise = activeWorkout.exercises[exerciseIndex]

        SecondaryControlViewOutlet.alpha = 0
        //SecondaryControlViewOutlet.isUserInteractionEnabled = false
        
        pauseContainer.layer.cornerRadius = 20
  //      skipButton.layer.cornerRadius = skipButton.frame.height / 2
        doneButton.layer.cornerRadius = 0
        
        nextExerciseButton.layer.cornerRadius = 0
        endWorkoutButton.layer.cornerRadius = 100
        
        bottomContainerView.layer.cornerRadius = 24
        PrimaryControlViewOutlet.isUserInteractionEnabled = true
        bottomContainerView.isUserInteractionEnabled = true
        setupBottomContainer()
               setupGestureRecognizers()
        setupPlayTap()
        configureUI()
        //setupBottomSheet()
    }
    private func setupBottomContainer() {
        // Style the container
        bottomContainerView.backgroundColor = .systemBackground
        bottomContainerView.layer.cornerRadius = 20
        bottomContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomContainerView.layer.shadowColor = UIColor.black.cgColor
        bottomContainerView.layer.shadowOpacity = 0.1
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomContainerView.layer.shadowRadius = 8
        
        // Style grabber
        grabberView.backgroundColor = .systemGray3
        grabberView.layer.cornerRadius = 2.5
        
        // Initially hide secondary view
        SecondaryControlViewOutlet.alpha = 0
        SecondaryControlViewOutlet.isHidden = true
        
        // Set initial height
        bottomContainerHeightConstraint.constant = collapsedHeight
    }
    private func setupGestureRecognizers() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bottomContainerView.addGestureRecognizer(panGestureRecognizer)
        
        // Also allow tap on grabber to toggle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGrabberTap))
        grabberView.addGestureRecognizer(tapGesture)
        grabberView.isUserInteractionEnabled = true
    }

    @objc private func handleGrabberTap() {
        toggleBottomContainer()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            let newHeight = bottomContainerHeightConstraint.constant - translation.y
            
            // Add rubber band effect at boundaries
            if newHeight >= collapsedHeight && newHeight <= expandedHeight {
                bottomContainerHeightConstraint.constant = newHeight
                
                let progress = (newHeight - collapsedHeight) / (expandedHeight - collapsedHeight)
                SecondaryControlViewOutlet.alpha = progress
                
                gesture.setTranslation(.zero, in: view)
            } else if newHeight < collapsedHeight {
                // Rubber band when dragging below collapsed
                let excess = collapsedHeight - newHeight
                bottomContainerHeightConstraint.constant = collapsedHeight - (excess * 0.1)
                gesture.setTranslation(.zero, in: view)
            } else if newHeight > expandedHeight {
                // Rubber band when dragging above expanded
                let excess = newHeight - expandedHeight
                bottomContainerHeightConstraint.constant = expandedHeight + (excess * 0.1)
                gesture.setTranslation(.zero, in: view)
            }
            
        case .ended:
            // Determine final state based on velocity and position
            let currentHeight = bottomContainerHeightConstraint.constant
            let midPoint = (collapsedHeight + expandedHeight) / 2
            
            if velocity.y < -500 { // Fast swipe up
                collapseBottomContainer()
            } else if velocity.y > 500 { // Fast swipe down
                expandBottomContainer()
            } else if currentHeight > midPoint {
                expandBottomContainer()
            } else {
                collapseBottomContainer()
            }
            
        default:
            break
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        
        
        // Reset to collapsed state when returning
           //     setSheetState(.collapsed, animated: false)
                
                // Resume timer if not paused
                if !isPaused {
                    startTimer()
                }
        //SetNumberOutlet.text=workoutExercise.
        configureUI()
        }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
        // Start timer on first appearance
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
        SetNumberOutlet.text = "Set \(currentSetIndex + 1)"

        //WeightOutlet.text = "\(currentSet.weightKg)"
        GifOutlet.image = exercise.gifImage
        GifOutlet.layer.cornerRadius = 20
        GifOutlet.layer.borderWidth = 1
        GifOutlet.layer.borderColor = UIColor.systemGray4.cgColor
        //GifOutlet.contentMode = AspectFit

//        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        updateTimerDisplay()
        
    }


 
    @IBAction func endWorkoutTapped(_ sender: UIButton) {
                print("end workout tap")
        
     //if alert is not needed simply uncomment this
//        timer?.invalidate()
//            finishWorkoutAndShowSummary()
            
        let alert = UIAlertController(
                title: "End Workout?",
                message: "Are you sure you want to end this workout?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "End Workout", style: .destructive) { [weak self] _ in
                self?.timer?.invalidate()
                self?.finishWorkoutAndShowSummary()
            })
            
            present(alert, animated: true)
        

               
    }
    @objc func pauseTapped() {
        isPaused.toggle()
        
        // Animate icon change with cross-dissolve
        UIView.transition(
            with: pauseOutlet,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            if self.isPaused {
                self.pauseOutlet.image = UIImage(systemName: "play.fill")
            } else {
                self.pauseOutlet.image = UIImage(systemName: "pause.fill")
            }
        }
        
        // Add bounce animation to pause container
        UIView.animate(withDuration: 0.1, animations: {
            self.pauseContainer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                self.pauseContainer.transform = .identity
            }
        }

        if isPaused {
            timer?.invalidate()
            expandBottomContainer()  // ADD: Auto-expand when paused
        } else {
            startTimer()
            collapseBottomContainer()  // ADD: Auto-collapse when resumed
        }
    }
    private func toggleBottomContainer() {
        if isExpanded {
            collapseBottomContainer()
        } else {
            expandBottomContainer()
        }
    }

    private func expandBottomContainer() {
        isExpanded = true
        SecondaryControlViewOutlet.isHidden = false
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            self.bottomContainerHeightConstraint.constant = self.expandedHeight
            self.SecondaryControlViewOutlet.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    private func collapseBottomContainer() {
        isExpanded = false
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            self.bottomContainerHeightConstraint.constant = self.collapsedHeight
            self.SecondaryControlViewOutlet.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.SecondaryControlViewOutlet.isHidden = true
        }
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
        
        // mark set complete
            exercise.sets[currentSetIndex].isCompleted = true
            activeWorkout.exercises[exerciseIndex] = exercise
            updateProgressBar()

            // go to rest
            performSegue(withIdentifier: "RestTimeStart", sender: nil)
        }
//    @IBAction func skipTapped(_ sender: UIButton) {
//        completeCurrentSet(skipped: true)
//    }
//    private func loadCurrentSet() {
//        // FIXED: Skip button should skip the current set, not go to rest
//                var exercise = activeWorkout.exercises[exerciseIndex]
//                
//        // Don't mark as completed when skipping
//                if currentSetIndex + 1 < exercise.sets.count {
//                    currentSetIndex += 1
//                    configureUI() // Reload UI for next set
//                    elapsedSeconds = 0 // Reset timer
//                    timer?.invalidate()
//                    startTimer()
//                } else {
//                    advanceToNextExerciseImmediately()
//                }
//    }
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
        elapsedSeconds=0
        
        if exerciseIndex >= activeWorkout.exercises.count {
            finishWorkout()
            return
        }

        workoutExercise = activeWorkout.exercises[exerciseIndex]
                configureUI()
                startTimer()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RestTimeStart" {
            guard let vc = segue.destination as? RestTimeViewController else { return }

            vc.onRestFinished = { [weak self] in
                self?.handlePostRest()
            }
        }
    }
    private func handlePostRest() {
        let exercise = activeWorkout.exercises[exerciseIndex]

        // More sets left in SAME exercise
        if currentSetIndex + 1 < exercise.sets.count {
            currentSetIndex += 1
            configureUI()        // update set + reps
            return
        }

        // Exercise finished → move to next
        moveToNextExercise()
    }
    private func moveToNextExercise() {
        exerciseIndex += 1

        // Workout finished
        if exerciseIndex >= activeWorkout.exercises.count {
            finishWorkoutAndShowSummary()
            return
        }

        // New exercise setup
        currentSetIndex = 0
        elapsedSeconds = 0
        timer?.invalidate()

        workoutExercise = activeWorkout.exercises[exerciseIndex]
        configureUI()
        startTimer()
    }


//    private func goToNextExercise() {
//        exerciseIndex += 1
//        currentSetIndex = 0
//        
//        if exerciseIndex >= activeWorkout.exercises.count {
//            finishWorkout()
//            return
//        }
//        
//        loadCurrentSet()
//    }
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
            //now completed workout added to the list of completed wokrouts 
            WorkoutSessionManager.shared.completedWorkouts.append(completedWorkout)
            
            let summaryVC = UIStoryboard(name: "Workout", bundle: nil)
                .instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
            
            summaryVC.completedWorkout = completedWorkout
        navigationController?.pushViewController(summaryVC, animated: true)
        
        }
        
    @IBAction func skipExerciseTapped(_ sender: UIButton) {
        timer?.invalidate()

        // Mark all remaining sets as skipped
        var exercise = activeWorkout.exercises[exerciseIndex]

            for i in currentSetIndex..<exercise.sets.count {
                exercise.sets[i].isCompleted = true
            }

            activeWorkout.exercises[exerciseIndex] = exercise
            //updateProgressBar()

            moveToNextExercise()
    }

    

   
}

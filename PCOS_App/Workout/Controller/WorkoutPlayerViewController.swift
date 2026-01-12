//
//  WorkoutPlayerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class WorkoutPlayerViewController: UIViewController {

    @IBOutlet weak var repetitionsText: UILabel!
    
    @IBOutlet weak var RepsOutlet: UILabel!
    @IBOutlet weak var SetNumberOutlet: UILabel!
    @IBOutlet weak var ProgressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var GifOutlet: UIImageView!
    
    @IBOutlet weak var PrimaryControlViewOutlet: UIView!
    
    
    //@IBOutlet weak var pauseOutlet: UIImageView!
    
    @IBOutlet weak var pauseContainer: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
   // @IBOutlet weak var skipButton: UIButton!
   // @IBOutlet weak var doneButton: UIButton!
    private var isPaused = false
   // private var isExpanded = false
    var timer: Timer?
    var elapsedSeconds = 0
    var workoutExercise: WorkoutExercise!
    var currentSetIndex: Int = 0
    @IBOutlet weak var paceButton: UIButton!

    @IBOutlet weak var bottomContainerView: UIView!
    
   // @IBOutlet weak var bottomSheetHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var grabberView: UIView!

    @IBOutlet weak var nextExerciseButton: UIButton!
    @IBOutlet weak var prevExerciseButton: UIButton!
    @IBOutlet weak var endWorkoutButton: UIBarButtonItem!
    
    
   // @IBOutlet weak var bottomContainerBottomConstraint: NSLayoutConstraint!

    // This controls the height (collapsed vs expanded)
  //  @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!

    
//    private let collapsedHeight: CGFloat = 170   // grabber + primary
//    private let expandedHeight: CGFloat = 220    // includes secondary
//    private var panGestureRecognizer: UIPanGestureRecognizer!

    
    var activeWorkout: ActiveWorkout!
    var exerciseIndex: Int = 0     // which exercise in routine
    
    enum Pace {
        case low
        case medium
        case high

        var secondsPerRep: Int {
            switch self {
            case .low: return 4
            case .medium: return 3
            case .high: return 2
            }
        }
    }
    private var selectedPace: Pace = .medium
    private var completedSetsInCurrentExercise = 0
    private var cardioCompleted = false


    override func viewDidLoad() {
        super.viewDidLoad()

        guard let activeWorkout = activeWorkout else {
            assertionFailure("activeWorkout not injected")
            return
        }

        self.activeWorkout = activeWorkout

        // SAFELY derive active workoutExercise
        self.workoutExercise = activeWorkout.exercises[exerciseIndex]

        
        pauseContainer.layer.cornerRadius = 20
  //      skipButton.layer.cornerRadius = skipButton.frame.height / 2
    //    doneButton.layer.cornerRadius = 0
        
        nextExerciseButton.layer.cornerRadius = 0
   //     endWorkoutButton.layer.cornerRadius = 100
        
        bottomContainerView.layer.cornerRadius = 24
        PrimaryControlViewOutlet.isUserInteractionEnabled = true
        bottomContainerView.isUserInteractionEnabled = true
        setupBottomContainer()
        //setupGestureRecognizers()
      //  setupPlayTap()
        configureUI()
        setupPaceMenu()
        //setupBottomSheet()
    }
    private func setupPaceMenu() {
        let low = UIAction(title: "Low", image: UIImage(systemName: "tortoise")) { _ in
            self.setPace(.low)
        }

        let medium = UIAction(title: "Medium", image: UIImage(systemName: "figure.walk")) { _ in
            self.setPace(.medium)
        }

        let high = UIAction(title: "High", image: UIImage(systemName: "hare")) { _ in
            self.setPace(.high)
        }

        paceButton.menu = UIMenu(
            title: "Pace",
            options: .displayInline,
            children: [low, medium, high]
        )

        paceButton.showsMenuAsPrimaryAction = true
    }
    private func setPace(_ pace: Pace) {
        //Hiding pace button for cardio exercises
        if workoutExercise.exercise.isCardio {
            paceButton.isHidden=true
        }
        selectedPace = pace

        paceButton.setTitle(paceTitle(pace), for: .normal)

        // Reset timer ONLY for strength exercises
        if !isPaused && !workoutExercise.exercise.isCardio {
            timer?.invalidate()
            elapsedSeconds = initialTimerSeconds()
            updateTimerDisplay()
            startTimer()
        }
        

    }
    private func paceTitle(_ pace: Pace) -> String {
        switch pace {
        case .low: return "Low Pace"
        case .medium: return "Medium Pace"
        case .high: return "High Pace"
        }
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
        
        elapsedSeconds = initialTimerSeconds()

        
        // Set initial height
       // bottomContainerHeightConstraint.constant = collapsedHeight
    }
    private func initialTimerSeconds() -> Int {
        let exercise = workoutExercise.exercise
        let currentSet = workoutExercise.sets[currentSetIndex]

        // 🫀 Cardio → fixed duration
        if exercise.isCardio {
            return currentSet.durationSeconds ?? 0
        }

        // 🏋️ Strength → reps × pace
        return currentSet.reps * selectedPace.secondsPerRep
    }


//    private func setupGestureRecognizers() {
//        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        bottomContainerView.addGestureRecognizer(panGestureRecognizer)
//        
//        // Also allow tap on grabber to toggle
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGrabberTap))
//        grabberView.addGestureRecognizer(tapGesture)
//        grabberView.isUserInteractionEnabled = true
//    }

//    @objc private func handleGrabberTap() {
//        toggleBottomContainer()
//    }

//    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: view)
//        let velocity = gesture.velocity(in: view)
//        
//        switch gesture.state {
//        case .changed:
//            let newHeight = bottomContainerHeightConstraint.constant - translation.y
//            
//            // Add rubber band effect at boundaries
//            if newHeight >= collapsedHeight && newHeight <= expandedHeight {
//                bottomContainerHeightConstraint.constant = newHeight
//                
//                let progress = (newHeight - collapsedHeight) / (expandedHeight - collapsedHeight)
//                SecondaryControlViewOutlet.alpha = progress
//                
//                gesture.setTranslation(.zero, in: view)
//            } else if newHeight < collapsedHeight {
                // Rubber band when dragging below collapsed
//                let excess = collapsedHeight - newHeight
//                bottomContainerHeightConstraint.constant = collapsedHeight - (excess * 0.1)
//                gesture.setTranslation(.zero, in: view)
//            } else if newHeight > expandedHeight {
//                // Rubber band when dragging above expanded
//                let excess = newHeight - expandedHeight
//                bottomContainerHeightConstraint.constant = expandedHeight + (excess * 0.1)
//                gesture.setTranslation(.zero, in: view)
//            }
//            
//        case .ended:
//            // Determine final state based on velocity and position
//            let currentHeight = bottomContainerHeightConstraint.constant
//            let midPoint = (collapsedHeight + expandedHeight) / 2
//            
//            if velocity.y < -500 { // Fast swipe up
//                collapseBottomContainer()
//            } else if velocity.y > 500 { // Fast swipe down
//                expandBottomContainer()
//            } else if currentHeight > midPoint {
//                expandBottomContainer()
//            } else {
//                collapseBottomContainer()
//            }
//            
//        default:
//            break
//        }
//    }
    

//    override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//        
//        
//        // Reset to collapsed state when returning
//           //     setSheetState(.collapsed, animated: false)
//                
//                // Resume timer if not paused
//                if !isPaused {
//                    elapsedSeconds = initialTimerSeconds()
//                    updateTimerDisplay()
//                    startTimer()
//
//                }
//        //SetNumberOutlet.text=workoutExercise.
//        configureUI()
//        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        elapsedSeconds = initialTimerSeconds()
        updateTimerDisplay()
        startTimer()
    }

       
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           
           // CRITICAL: Stop timer when leaving this view
           timer?.invalidate()
           timer = nil
       }

//    private func setupPlayTap() {
//        pauseOutlet.isUserInteractionEnabled = true
//
//        let tapGesture = UITapGestureRecognizer(
//            target: self,
//            action: #selector(pauseTapped)
//        )
//
//        pauseOutlet.addGestureRecognizer(tapGesture)
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
//        RepsOutlet.text = "\(currentSet.reps)"
        if workoutExercise.exercise.isCardio {
            RepsOutlet.text = "Duration: \(currentSet.durationSeconds ?? 0)s"
            repetitionsText.isHidden=true
        } else {
            RepsOutlet.text = "\(currentSet.reps)"
            repetitionsText.isHidden=false
        }
//        SetNumberOutlet.text = "Set \(currentSetIndex + 1)"
        if workoutExercise.exercise.isCardio {
            //SetNumberOutlet.text = "Cardio"
             SetNumberOutlet.isHidden = true
        } else {
            SetNumberOutlet.text = "Set \(currentSetIndex + 1) of \(workoutExercise.sets.count)"
            SetNumberOutlet.isHidden = false
        }

        //WeightOutlet.text = "\(currentSet.weightKg)"
        GifOutlet.image = exercise.gifImage
        GifOutlet.layer.cornerRadius = 20
        GifOutlet.layer.borderWidth = 1
        GifOutlet.layer.borderColor = UIColor.systemGray4.cgColor
        //GifOutlet.contentMode = AspectFit
        paceButton.isHidden = workoutExercise.exercise.isCardio
        //disabling next,prev for last,first 
        updatePrevNextButtonState()
//        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        updateTimerDisplay()
        
        
    }

    @IBAction func crossTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
 
    @IBAction func endWorkoutTapped(_ sender: UIBarButtonItem) {
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
//    @objc func pauseTapped() {
//        isPaused.toggle()
//        
//        // Animate icon change with cross-dissolve
//        UIView.transition(
//            with: pauseOutlet,
//            duration: 0.2,
//            options: .transitionCrossDissolve
//        ) {
//            if self.isPaused {
//                self.pauseOutlet.image = UIImage(systemName: "play.fill")
//            } else {
//                self.pauseOutlet.image = UIImage(systemName: "pause.fill")
//            }
//        }
        
        // Add bounce animation to pause container
//        UIView.animate(withDuration: 0.1, animations: {
//            self.pauseContainer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        }) { _ in
//            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
//                self.pauseContainer.transform = .identity
//            }
//        }

//        if isPaused {
//            timer?.invalidate()
//           // expandBottomContainer()  // ADD: Auto-expand when paused
//        } else {
//            startTimer()
            //collapseBottomContainer()  // ADD: Auto-collapse when resumed
    //    }
  //  }
//    private func toggleBottomContainer() {
//        if isExpanded {
//            collapseBottomContainer()
//        } else {
//            expandBottomContainer()
//        }
//    }

//    private func expandBottomContainer() {
//        isExpanded = true
//        SecondaryControlViewOutlet.isHidden = false
//        
//        UIView.animate(
//            withDuration: 0.4,
//            delay: 0,
//            usingSpringWithDamping: 0.8,
//            initialSpringVelocity: 0.5,
//            options: [.curveEaseInOut, .allowUserInteraction]
//        ) {
//            self.bottomContainerHeightConstraint.constant = self.expandedHeight
//            self.SecondaryControlViewOutlet.alpha = 1
//            self.view.layoutIfNeeded()
//        }
//    }

//    private func collapseBottomContainer() {
//        isExpanded = false
//        
//        UIView.animate(
//            withDuration: 0.4,
//            delay: 0,
//            usingSpringWithDamping: 0.8,
//            initialSpringVelocity: 0.5,
//            options: [.curveEaseInOut, .allowUserInteraction]
//        ) {
//            self.bottomContainerHeightConstraint.constant = self.collapsedHeight
//            self.SecondaryControlViewOutlet.alpha = 0
//            self.view.layoutIfNeeded()
//        } completion: { _ in
//            self.SecondaryControlViewOutlet.isHidden = true
//        }
//    }

    private func startTimer() {
        timer?.invalidate()

        guard elapsedSeconds > 0 else {
            handleTimerFinished()
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.elapsedSeconds -= 1
            self.updateTimerDisplay()

            if self.elapsedSeconds <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.handleTimerFinished()
            }
        }
    }
    private func handleTimerFinished() {
        completeCurrentSet(skipped: false)
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
//    @IBAction func doneTapped(_ sender: UIButton) {
//        completeCurrentSet(skipped: false)
//    }
    private func completeCurrentSet(skipped: Bool) {
        timer?.invalidate()
        
        var exercise = activeWorkout.exercises[exerciseIndex]
        
        // MARK: Cardio logic
        if exercise.exercise.isCardio {
            guard elapsedSeconds <= 0 else { return }

            exercise.sets[0].isCompleted = true
            activeWorkout.exercises[exerciseIndex] = exercise
            cardioCompleted = true

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
    @IBAction func nextTapped(_ sender: UIButton) {
        timer?.invalidate()

            // Cardio skipped early → not completed
            if workoutExercise.exercise.isCardio {
                cardioCompleted = false
            }

            advanceToNextExerciseImmediately()
    }
    //initially :loadcurrentset
    private func loadNextFirstSet() {
        // FIXED: Skip button should skip the current set, not go to rest
                var exercise = activeWorkout.exercises[exerciseIndex]
                
        // Don't mark as completed when skipping
                if currentSetIndex + 1 < exercise.sets.count {
                    currentSetIndex += 1
                    configureUI() // Reload UI for next set
                    
                    elapsedSeconds = initialTimerSeconds()
                    updateTimerDisplay()
                    startTimer()


                } else {
                    advanceToNextExerciseImmediately()
                }
    }
    @IBAction func previousTapped(_ sender: UIButton) {
        timer?.invalidate()
            goToPreviousLogicalSet()
    }
    private func goToPreviousLogicalSet() {

        // 1️⃣ Try within SAME exercise
        let sets = workoutExercise.sets

        if currentSetIndex > 0 {
            // Go to previous set
            currentSetIndex -= 1
            loadCurrentSetWithoutCompletion()
            return
        }

        // 2️⃣ Move to PREVIOUS exercise
        guard exerciseIndex > 0 else { return }

        exerciseIndex -= 1
        workoutExercise = activeWorkout.exercises[exerciseIndex]

        let previousSets = workoutExercise.sets

        // Find last completed set
        if let lastCompletedIndex = previousSets.lastIndex(where: { $0.isCompleted }) {
            currentSetIndex = lastCompletedIndex
        } else {
            // All sets were skipped → load last set
            currentSetIndex = previousSets.count - 1
        }

        loadCurrentSetWithoutCompletion()
    }
    private func loadCurrentSetWithoutCompletion() {
        elapsedSeconds = initialTimerSeconds()
        configureUI()
        updateTimerDisplay()
        startTimer()
    }

    private func loadPreviousLastSet() {
        // FIXED: Skip button should skip the current set, not go to rest
                var exercise = activeWorkout.exercises[exerciseIndex]
                
        // Don't mark as completed when skipping
                if currentSetIndex + 1 < exercise.sets.count {
                    //i.e. if current exercise ke aur sets baaki hai
                    currentSetIndex += 1
                    configureUI() // Reload UI for next set
                    
                    elapsedSeconds = initialTimerSeconds()
                    updateTimerDisplay()
                    startTimer()


                } else {
                    advanceToNextExerciseImmediately()
                }
    }
    
    
    
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
        elapsedSeconds = initialTimerSeconds()
        updateTimerDisplay()
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
            configureUI()
            elapsedSeconds = initialTimerSeconds()
            updateTimerDisplay()
            startTimer()
            return
        }

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
        elapsedSeconds = initialTimerSeconds()
        updateTimerDisplay()
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
   //UNCOMMENT IF NEED : SKIP EXERCSIE instead of set
    
//    @IBAction func skipExerciseTapped(_ sender: UIButton) {
//        timer?.invalidate()
//
//        // Mark all remaining sets as skipped
//        var exercise = activeWorkout.exercises[exerciseIndex]
//
//            for i in currentSetIndex..<exercise.sets.count {
//                exercise.sets[i].isCompleted = true
//            }
//
//            activeWorkout.exercises[exerciseIndex] = exercise
//            //updateProgressBar()
//
//            moveToNextExercise()
//    }

    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        
            isPaused.toggle()

            if isPaused {
                // PAUSE
                sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
                timer?.invalidate()
                timer = nil
            } else {
                // PLAY / RESUME
                sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                startTimer()
            }
        }
//disabling next,prev on last,first set of last,first exercise
    private func updatePrevNextButtonState() {

        // Disable Prev only on first set of first exercise
        let isFirstExercise = exerciseIndex == 0
        let isFirstSet = currentSetIndex == 0
        prevExerciseButton.isEnabled = !(isFirstExercise && isFirstSet)

        // Disable Next only on last set of last exercise
        let isLastExercise = exerciseIndex == activeWorkout.exercises.count - 1
        let isLastSet = currentSetIndex == workoutExercise.sets.count - 1
        nextExerciseButton.isEnabled = !(isLastExercise && isLastSet)

        // Optional UX polish
        prevExerciseButton.alpha = prevExerciseButton.isEnabled ? 1.0 : 0.4
        nextExerciseButton.alpha = nextExerciseButton.isEnabled ? 1.0 : 0.4
    }


   
}

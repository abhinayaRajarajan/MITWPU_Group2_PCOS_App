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
    @IBOutlet weak var ExerciseNameOutlet: UILabel!
    @IBOutlet weak var ProgressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var GifOutlet: UIImageView!
    @IBOutlet weak var SecondaryControlViewOutlet: UIView!
    @IBOutlet weak var PrimaryControlViewOutlet: UIView!
    @IBOutlet weak var pauseButton: UIButton!
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

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SecondaryControlViewOutlet.alpha = 0
        SecondaryControlViewOutlet.isUserInteractionEnabled = false
        
        configureUI()
        setupBottomSheet()
        //startTimer()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }

    private func configureUI() {
        guard let workoutExercise = workoutExercise else {
            assertionFailure("WorkoutExercise not injected before WorkoutPlayerViewController loaded")
            return
        }

        let exercise = workoutExercise.exercise
        let currentSet = workoutExercise.sets[currentSetIndex]

        ExerciseNameOutlet.text = exercise.name
        RepsOutlet.text = "\(currentSet.reps)"
        WeightOutlet.text = "\(currentSet.weightKg)"
        GifOutlet.image = exercise.gifImage

        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
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
        let targetAlpha: CGFloat = (state == .expanded) ? 1 : 0
        let isInteractionEnabled = (state == .expanded)
        
        bottomSheetBottomConstraint.constant = targetOffset
        
        let animations = {
            self.SecondaryControlViewOutlet.alpha = targetAlpha
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.6,
                options: [.curveEaseOut],
                animations: animations,
                completion: { _ in
                    self.SecondaryControlViewOutlet.isUserInteractionEnabled = isInteractionEnabled
                }
            )
        } else {
            animations()
            SecondaryControlViewOutlet.isUserInteractionEnabled = isInteractionEnabled
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
    @IBAction func pauseTapped(_ sender: UIButton) {
        isPaused.toggle()
            
            if isPaused {
                timer?.invalidate()
                pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                
                // EXPAND the sheet when pausing (like Apple Fitness)
                setSheetState(.expanded, animated: true)
                
            } else {
                startTimer()
                pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                
                // COLLAPSE the sheet when resuming
                setSheetState(.collapsed, animated: true)
            }
    }
    @IBAction func endWorkoutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
                title: "End Workout?",
                message: "This will stop your current workout.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "End", style: .destructive) { _ in
                self.timer?.invalidate()
                self.dismiss(animated: true)
            })
            
            present(alert, animated: true)
    }
    @IBAction func lockControlsTapped(_ sender: UIButton) {
        // Disable all controls
            [skipButton, doneButton, pauseButton].forEach {
                $0?.isEnabled = false
                $0?.alpha = 0.4
            }
            
            // Collapse the sheet
            setSheetState(.collapsed, animated: true)
            
            // Optional: Add a tap-to-unlock gesture
            // addUnlockGesture()
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
   
}

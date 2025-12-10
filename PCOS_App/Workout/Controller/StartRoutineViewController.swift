//
//  StartRoutineViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class StartRoutineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeWorkout.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "start_routine_exercise_cell",
                for: indexPath
            ) as? StartRoutineExerciseTableViewCell else {
                return UITableViewCell()
            }

            let exercise = activeWorkout.exercises[indexPath.row]

            cell.configure(with: exercise)
            
        
        
        cell.onDoneTapped = { [weak self] isCompleted in
            self?.toggleSet(
                exerciseIndex: indexPath.row,
                isCompleted: isCompleted
            )
        }

            return cell
        }
    func toggleSet(exerciseIndex: Int, isCompleted: Bool) {

        // Your workout always has 1 set per exercise (based on your model)
        var set = activeWorkout.exercises[exerciseIndex].sets[0]
        set.isCompleted = isCompleted
        activeWorkout.exercises[exerciseIndex].sets[0] = set

        // Recalculate everything
        updateProgress()
        updateStats()

        // Reload only this row
        startRoutineTableView.reloadRows(
            at: [IndexPath(row: exerciseIndex, section: 0)],
            with: .automatic
        )
    }

    

    var activeWorkout: ActiveWorkout!
    var globalTimer: Timer?
    // Which routine to load (pass this from previous screen)
        var selectedRoutineIndex: Int = 0  // Default to first routine
        
        var totalSets: Int {
            activeWorkout.exercises.flatMap { $0.sets }.count
        }
        
        var completedSets: Int {
            activeWorkout.exercises.flatMap { $0.sets }.filter { $0.isCompleted }.count
        }
        
        var completedExercises: Int {
            activeWorkout.exercises.filter { exercise in
                exercise.sets.allSatisfy { $0.isCompleted }
            }.count
        }



    @IBOutlet weak var routineProgressBar: UIView!
    @IBOutlet weak var setCountOutlet: UILabel!
    @IBOutlet weak var finishRoutineButton: UIBarButtonItem!
    @IBOutlet weak var exercisesCountOutlet: UILabel!
    @IBOutlet weak var durationLabelOutlet: UILabel!
    
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var routineNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Get the first saved routine (or pass index from previous screen)
            // TEMPORARY: For testing, we'll use the first routine
//            guard let routine = WorkoutSessionManager.shared.savedRoutines.first else {
//                // Show error if no routine exists
//                let alert = UIAlertController(
//                    title: "No Routine Found",
//                    message: "Please create a routine first.",
//                    preferredStyle: .alert
//                )
//                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//                    self.navigationController?.popViewController(animated: true)
//                })
//                present(alert, animated: true)
//                return
//            }
        
            
//            print("🏋️ Starting routine: \(routine.name)")
//            print("📋 Exercises count: \(routine.exercises.count)")
//
//            // 2. Convert RoutineExercise → WorkoutExercise (live set-tracking)
//            let workoutExercises = routine.exercises.map { $0.generateWorkoutExercise() }
//            
//            print("✅ Generated \(workoutExercises.count) workout exercises")
//
//            // 3. Create the active workout
//            activeWorkout = ActiveWorkout(
//                routine: routine,
//                exercises: workoutExercises
//            )
//
//            WorkoutSessionManager.shared.activeWorkout = activeWorkout
//
//            routineNameLabel.text = routine.name
//
//            startRoutineTableView.delegate = self
//            startRoutineTableView.dataSource = self
//            setupTable()
//            startMainTimer()
//            updateStats()
//            updateProgress()
        // 1️⃣ Get the active workout that was set earlier
            guard let session = WorkoutSessionManager.shared.activeWorkout else {
                print("❌ No active workout found!")
                navigationController?.popViewController(animated: true)
                return
            }

            activeWorkout = session

            print("🏋️ Starting routine: \(session.routine.name)")
            print("📋 Exercises count: \(session.exercises.count)")

            // 2️⃣ Set UI
            routineNameLabel.text = session.routine.name

            // 3️⃣ Setup Table
            startRoutineTableView.delegate = self
            startRoutineTableView.dataSource = self
        startRoutineTableView.rowHeight = UITableView.automaticDimension
        startRoutineTableView.estimatedRowHeight = 200
            setupTable()

            // 4️⃣ Start timer
            startMainTimer()

            // 5️⃣ Update stats & progress
            updateStats()
            updateProgress()
    }
    
    @IBOutlet weak var startRoutineTableView: UITableView!
    
    func setupTable() {
        
        startRoutineTableView.register(
            UINib(nibName: "StartRoutineExerciseTableViewCell", bundle: nil),
            forCellReuseIdentifier: "start_routine_exercise_cell"
        )
    }
    func startMainTimer() {
        globalTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let elapsed = Int(Date().timeIntervalSince(self.activeWorkout.startTime))
            let minutes = elapsed / 60
            let seconds = elapsed % 60
            // ✅ Shows "7:23" format
            self.durationLabelOutlet.text = String(format: "%d:%02d", minutes, seconds)
        }
    }
    func updateStats() {

        // Show completed exercises
        exercisesCountOutlet.text = "\(completedExercises)"

        // Show completed sets
        setCountOutlet.text = "\(completedSets)"

        // Ignore volume as per your requirement
    }
    func updateProgress() {
        let total = totalSets
        let done = completedSets
        
        let progress = total == 0 ? 0 : CGFloat(done) / CGFloat(total)

        let maxWidth = view.frame.width - 40  // adjust based on layout
        let newWidth = maxWidth * progress

        UIView.animate(withDuration: 0.25) {
            self.progressWidthConstraint.constant = newWidth
            self.view.layoutIfNeeded()
        }
    }

//    func markSetCompleted(exerciseIndex: Int, setIndex: Int) {
//        activeWorkout.exercises[exerciseIndex].sets[setIndex].isCompleted = true
//
//        updateProgress()
//        updateStats()
//
//        // Optional: reload that specific row for visual update
//        startRoutineTableView.reloadRows(at: [IndexPath(row: exerciseIndex, section: 0)], with: .automatic)
//    }

    @IBAction func finishRoutineTapped(_ sender: UIBarButtonItem) {

        let elapsed = Int(Date().timeIntervalSince(activeWorkout.startTime))

        if elapsed < 300 {
            let alert = UIAlertController(
                title: "Workout Too Short",
                message: "Workout must be at least 5 minutes.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        globalTimer?.invalidate()
        activeWorkout.finish()

        let completedWorkout = CompletedWorkout(
            routineName: activeWorkout.routine.name,
            date: Date(),
            durationSeconds: activeWorkout.durationSeconds,
            exercises: activeWorkout.exercises
        )

        WorkoutSessionManager.shared.completedWorkouts.append(completedWorkout)
        
        print("💾 Workout saved: \(completedWorkout.routineName) - Duration: \(completedWorkout.durationSeconds)s")

           
        navigationController?.popViewController(animated: true)
    }



}

//
//  CreateRoutineViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class CreateRoutineViewController: UIViewController {
    // Same VC for before and after adding exercise - Apple's Guidelines (Human Interface Guidelines) "Within a screen, adapt content to reflect state changes."

    
    @IBOutlet weak var saveRoutineButton: UIBarButtonItem!
    
    @IBOutlet weak var routineNameTextField: UITextField!
    
    @IBOutlet weak var estimatedDurationLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet weak var exerciseCountLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var emptyStateImageView: UIImageView!
    @IBOutlet weak var emptyStateAddButton: UIButton!
    
    @IBOutlet weak var exerciseTableView: UITableView!
    
    private var routineExercises: [RoutineExercise] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveRoutineButton.isEnabled = false
        
        setupUI()
        registerCells()
        updateUI()

        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
            containerView.bringSubviewToFront(exerciseTableView)
            
            exerciseTableView.delegate = self
            exerciseTableView.dataSource = self
            exerciseTableView.estimatedRowHeight = 88
            exerciseTableView.rowHeight = UITableView.automaticDimension
            
        }
    
    func registerCells() {
        exerciseTableView.register(
            UINib(
                nibName: "RoutineExerciseTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "routine_exercise_cell"
        )
    }
    
    private func updateUI() {
            let hasExercises = !routineExercises.isEmpty
            
            // Toggle visibility
            emptyStateView.isHidden = hasExercises
            exerciseTableView.isHidden = !hasExercises
            
            // Update stats
            updateStats()
            saveRoutineButton.isEnabled = hasExercises
            
            // Reload table
            exerciseTableView.reloadData()
        }
    
    private func updateStats() {
    // Exercise count
    exerciseCountLabel.text = "\(routineExercises.count)"
            
            
            //OLD CODE WITH PLANNED SETS STRUCT(now deleted)
    //            // Total sets
    //            let totalSets = routineExercises.reduce(0) { $0 + $1.totalSets }
    //            setCountLabel.text = "\(totalSets)"
    //
    //            // Estimated duration
    //            let totalDuration = routineExercises.reduce(0) { $0 + $1.estimatedDuration }
    //            estimatedDurationLabel.text = formatDuration(totalDuration)
            
    let totalDuration = routineExercises.reduce(0) { total, ex in
            if ex.exercise.isCardio {
                return total + (ex.durationSeconds ?? 0)
            } else {
                let active = ex.reps * 4
                let rest = ex.restTimerSeconds ?? 0
                return total + (active + rest) * ex.numberOfSets
            }
        }
        estimatedDurationLabel.text = formatDuration(totalDuration)
    }

    
    private func formatDuration(_ seconds: Int) -> String {
            let minutes = seconds / 60
            if minutes > 60 {
                let hours = minutes / 60
                let remainingMinutes = minutes % 60
                return "\(hours)h \(remainingMinutes)m"
            }
            return "\(minutes)m"
        }
    

    @IBAction func showAddExerciseOnTap(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddExercise", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showAddExercise" {
//                if let navController = segue.destination as? UINavigationController,
//                   let addExerciseVC = navController.topViewController as? AddExerciseViewController {
//                    
//                    // Pass callback to receive selected exercises
//                    addExerciseVC.onExercisesSelected = { [weak self] selectedExercises in
//                        self?.handleSelectedExercises(selectedExercises)
//                    }
//                }
                if let addVC = segue.destination as? AddExerciseViewController {
                            addVC.onExercisesSelected = { [weak self] selectedExercises in
                                self?.handleSelectedExercises(selectedExercises)
                            }
                        }
            }
        }
    
    private func handleSelectedExercises(_ exercises: [Exercise]) {
        // Convert Exercise to RoutineExercise with default sets
               
               //OLD CODE WITH PLANNED SETS STRUCT(now deleted)
       //            let newRoutineExercises = exercises.map { exercise in
       //                RoutineExercise(
       //                    exercise: exercise,
       //                    sets: [
       //                        PlannedSet(setNumber: 1, reps: 10, weightKg: 0, restTimerSeconds: 60)
       //                    ]
       //                )
       //            }
               
               let newRoutineExercises = exercises.map { exercise in
                   RoutineExercise(exercise: exercise)
               }
                   
                   // Add to existing exercises
                   routineExercises.append(contentsOf: newRoutineExercises)
                   
                   // Update UI
                   updateUI()
               }
           }

// MARK: - UITableViewDataSource
extension CreateRoutineViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routineExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "routine_exercise_cell",
            for: indexPath
        ) as? RoutineExerciseTableViewCell else {
            return UITableViewCell()
        }
        
        let routineExercise = routineExercises[indexPath.row]
        
        // Configure cell using the configure method
        cell.configure(with: routineExercise)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateRoutineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Navigate to exercise detail/edit screen
    }
    
    // Enable swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            routineExercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateUI()
        }
    }
}


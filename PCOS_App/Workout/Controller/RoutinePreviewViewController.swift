//
//  RoutinePreviewViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class RoutinePreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routine.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "routine_preview_cell",
                    for: indexPath
                ) as? RoutinePreviewTableViewCell else {
                    return UITableViewCell()
                }

                let routineExercise = routine.exercises[indexPath.row]
                cell.configure(with: routineExercise)

                cell.onInfoTapped = { [weak self] in
                    self?.showExerciseInfo(routineExercise.exercise)
                }

                return cell
    }
    

    @IBOutlet weak var EstRoutineTimeOutlet: UILabel!
    @IBOutlet weak var NoOfExerciseOutlet: UILabel!
   // @IBOutlet weak var RoutineNameOutlet: UILabel!
    @IBOutlet weak var RoutineImageOutlet: UIImageView!
    
    @IBOutlet weak var timeTagContainer: UIView!
    
    @IBOutlet weak var exerciseTagContainer: UIView!
    @IBOutlet weak var RoutinePreviewTableViewOutlet: UITableView!
    @IBOutlet weak var playImageView: UIImageView!

    var routine: Routine!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = routine.name
        view.backgroundColor=UIColor(hex: "#FCEEED")
        navigationController?.navigationBar.prefersLargeTitles = false
        setupContainerStyle()
        configureRoutineHeader()
        setupTable()
        setupPlayTap()
        
    }
    private func setupPlayTap() {
        playImageView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(playTapped)
        )

        playImageView.addGestureRecognizer(tapGesture)
    }
    @objc private func playTapped() {
        startWorkout()
    }
    private func startWorkout() {
            // Create workout exercises from routine
            let workoutExercises = routine.exercises.map {
                $0.generateWorkoutExercise()
            }

            // Create active workout
            let activeWorkout = ActiveWorkout(
                routine: routine,
                exercises: workoutExercises
            )

            WorkoutSessionManager.shared.activeWorkout = activeWorkout

            let storyboard = UIStoryboard(name: "Workout", bundle: nil)

            // Present countdown
            guard let countdownVC = storyboard.instantiateViewController(
                withIdentifier: "CountdownViewController"
            ) as? CountdownViewController else {
                print("❌ Failed to instantiate CountdownViewController")
                return
            }

            countdownVC.modalPresentationStyle = .fullScreen

            // Set up the callback for when countdown finishes
            countdownVC.onCountdownFinished = { [weak self] in
                guard let self = self else { return }

                // Create the workout player
                guard let workoutVC = storyboard.instantiateViewController(
                    withIdentifier: "WorkoutPlayerViewController"
                ) as? WorkoutPlayerViewController else {
                    print("Failed to instantiate WorkoutPlayerViewController")
                    return
                }

                
                workoutVC.activeWorkout = activeWorkout
                workoutVC.exerciseIndex = 0
                workoutVC.workoutExercise = activeWorkout.exercises[0]

                // ✅ FIX: Wrap in navigation controller 
                let navController = UINavigationController(rootViewController: workoutVC)
                navController.modalPresentationStyle = .fullScreen

                // Present the navigation controller
                self.present(navController, animated: true)
            }

            // Present countdown
            present(countdownVC, animated: false)
        }



    private func setupContainerStyle() {
        timeTagContainer.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        timeTagContainer.layer.cornerRadius = exerciseTagContainer.frame.height / 2
        exerciseTagContainer.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        exerciseTagContainer.layer.cornerRadius = exerciseTagContainer.frame.height / 2
        RoutineImageOutlet.layer.cornerRadius=0
    }
    private func configureRoutineHeader() {
       // RoutineNameOutlet.text = routine.name
        NoOfExerciseOutlet.text = "\(routine.totalExercises) Exercises"
        EstRoutineTimeOutlet.text = routine.formattedDuration
        setRoutineImage()
    }

    private func setRoutineImage() {
        if let imageName = routine.thumbnailImageName {
            RoutineImageOutlet.image = UIImage(named: imageName)
            RoutineImageOutlet.contentMode = .scaleAspectFill
        }
    }
    private func setupTable() {
        RoutinePreviewTableViewOutlet.delegate = self
        RoutinePreviewTableViewOutlet.dataSource = self
        //RoutinePreviewTableViewOutlet.rowHeight = UITableView.automaticDimension
        //RoutinePreviewTableViewOutlet.estimatedRowHeight = 200
        RoutinePreviewTableViewOutlet.rowHeight = 120
        RoutinePreviewTableViewOutlet.register(
            UINib(nibName: "RoutinePreviewTableViewCell", bundle: nil),
            forCellReuseIdentifier: "routine_preview_cell"
        )
    }
    private func showExerciseInfo(_ exercise: Exercise) {
        performSegue(withIdentifier: "InfoModal", sender: exercise)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InfoModal" {
            
            // Case 1: modal embedded in navigation controller
            if let nav = segue.destination as? UINavigationController,
               let infoVC = nav.topViewController as? InfoModalViewController,
               let exercise = sender as? Exercise {
                infoVC.exercise = exercise
            }
            
            
        }
           
    }
    
    

}

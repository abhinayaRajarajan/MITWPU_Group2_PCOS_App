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
    @IBOutlet weak var RoutineNameOutlet: UILabel!
    @IBOutlet weak var RoutineImageOutlet: UIImageView!
    @IBOutlet weak var RoutineDetailStack: UIStackView!
    
    @IBOutlet weak var RoutinePreviewTableViewOutlet: UITableView!
    var routine: Routine!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupContainerStyle()
        configureRoutineHeader()
        setupTable()
      
        
    }
    
    private func setupContainerStyle() {
        RoutineDetailStack.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        RoutineDetailStack.layer.cornerRadius = 16
        RoutineDetailStack.layer.shadowColor = UIColor.black.cgColor
        RoutineDetailStack.layer.shadowOpacity = 0.15
        RoutineDetailStack.layer.shadowOffset = CGSize(width: 0, height: 4)
        RoutineDetailStack.layer.shadowRadius = 12
        
        addBlurEffect()
    }
    private func configureRoutineHeader() {
        RoutineNameOutlet.text = routine.name
        NoOfExerciseOutlet.text = "\(routine.totalExercises)"
        EstRoutineTimeOutlet.text = routine.formattedDuration
        setRoutineImage()
    }

    private func setRoutineImage() {
        if let imageName = routine.thumbnailImageName {
            RoutineImageOutlet.image = UIImage(named: imageName)
        }
    }
    private func setupTable() {
        RoutinePreviewTableViewOutlet.delegate = self
        RoutinePreviewTableViewOutlet.dataSource = self
       RoutinePreviewTableViewOutlet.rowHeight = UITableView.automaticDimension
        RoutinePreviewTableViewOutlet.estimatedRowHeight = 120
        
        RoutinePreviewTableViewOutlet.register(
            UINib(nibName: "RoutinePreviewTableViewCell", bundle: nil),
            forCellReuseIdentifier: "routine_preview_cell"
        )
    }
    private func showExerciseInfo(_ exercise: Exercise) {
        performSegue(withIdentifier: "InfoModal", sender: exercise)
    }

    @IBAction func startWorkoutTapped(_ sender: UIButton) {
//        let workoutExercises = routine.exercises.map {
//            $0.generateWorkoutExercise()
//        }
//
//        let activeWorkout = ActiveWorkout(
//            routine: routine,
//            exercises: workoutExercises
//        )
//
//        WorkoutSessionManager.shared.activeWorkout = activeWorkout
//        performSegue(withIdentifier: "startWorkout", sender: nil)
        let workoutExercises = routine.exercises.map {
                $0.generateWorkoutExercise()
            }

            let activeWorkout = ActiveWorkout(
                routine: routine,
                exercises: workoutExercises
            )

            WorkoutSessionManager.shared.activeWorkout = activeWorkout

            let storyboard = UIStoryboard(name: "Workout", bundle: nil)

            guard let countdownVC = storyboard.instantiateViewController(
                withIdentifier: "CountdownViewController"
            ) as? CountdownViewController else { return }

            countdownVC.modalPresentationStyle = .fullScreen

            countdownVC.onCountdownFinished = { [weak self] in
                guard let self = self else { return }

                let workoutVC = storyboard.instantiateViewController(
                    withIdentifier: "WorkoutPlayerViewController"
                ) as! WorkoutPlayerViewController

                workoutVC.workoutExercise = activeWorkout.exercises.first

                self.navigationController?.pushViewController(workoutVC, animated: true)
            }

            present(countdownVC, animated: false)
        
        
        
        
        
        
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
//        if segue.identifier == "startWorkout",
//               let workoutVC = segue.destination as? WorkoutPlayerViewController,
//               let activeWorkout = WorkoutSessionManager.shared.activeWorkout {
//
//                // Start with first exercise
//                workoutVC.workoutExercise = activeWorkout.exercises.first
//            }

//            
    }
    private func addBlurEffect() {
        // Remove any existing blur
        RoutineDetailStack.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        
        // Create blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        
        // Insert blur as background
        RoutineDetailStack.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: RoutineDetailStack.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: RoutineDetailStack.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: RoutineDetailStack.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: RoutineDetailStack.bottomAnchor)
        ])
        
        // Make container background clear so blur shows
        RoutineDetailStack.backgroundColor = .clear
    }

}

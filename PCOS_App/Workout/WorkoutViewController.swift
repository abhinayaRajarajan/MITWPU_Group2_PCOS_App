//
//  WorkoutViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

enum ExploreRoutineItem {
    case createCustom
    case predefined(Routine)
}

class WorkoutViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    private var exploreItems: [ExploreRoutineItem] = []
        
    
    @IBOutlet weak var durationGoalCard: UIView!
    @IBOutlet weak var stepsGoalCard: UIView!
    @IBOutlet weak var caloriesGoalCard: UIView!
    
    @IBOutlet weak var myRoutinesSuperView: UIView!
    @IBOutlet weak var emptyMyRoutineOutlet: UIView!
    @IBOutlet weak var myRoutinesCollectionOutlet: UICollectionView!
    
    @IBOutlet weak var exploreRoutinesCollectionOutlet: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Workout"
        navigationController?.navigationBar.prefersLargeTitles = true
            registerCells()
            
            exploreRoutinesCollectionOutlet.dataSource = self
            exploreRoutinesCollectionOutlet.delegate = self

            myRoutinesCollectionOutlet.dataSource = self
            myRoutinesCollectionOutlet.delegate = self

        // Use a flow layout configured for horizontal scrolling if needed
            if let layout = myRoutinesCollectionOutlet.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumInteritemSpacing = 12
                layout.minimumLineSpacing = 12
                layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            }
    
            //setting up the explore
            setupExploreData()
    }
    
    private func setupExploreData() {
        exploreItems=[
            .createCustom
        ] + RoutineDataStore.shared.predefinedRoutines.map {.predefined($0)}
    }
//Error code :
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return exploreItems.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "explore_routines_cell", for: indexPath) as! ExploreRoutinesCollectionViewCell
//        
//        let item=exploreItems[indexPath.item]
//        switch item {
//        case .createCustom:
//            cell.configureCreateRoutine()
//        case .predefined(let routine):
//            cell.configureRoutine(routine)
//        }
//        return cell
//    }
    
 //   Distinguish between collection views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == exploreRoutinesCollectionOutlet {
            return exploreItems.count
        } else {
            // Return count for myRoutinesCollectionOutlet
            return WorkoutSessionManager.shared.savedRoutines.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == exploreRoutinesCollectionOutlet {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "explore_routines_cell",
                for: indexPath
            ) as! ExploreRoutinesCollectionViewCell
            
            let item = exploreItems[indexPath.item]
            switch item {
            case .createCustom:
                cell.configureCreateRoutine()

                    // ADD CALLBACK
                    cell.onCreateRoutineTapped = { [weak self] in
                        self?.handleCreateCustomRoutine()
                    }
            case .predefined(let routine):
                cell.configureRoutine(routine)
            }
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "my_routines_cell",
                for: indexPath
            ) as! MyRoutinesCollectionViewCell

            let routine = WorkoutSessionManager.shared.savedRoutines[indexPath.item]
            cell.configure(with: routine)

            
            cell.onStartTapped = { [weak self] in
                guard let self = self else { return }

                print("▶️ Starting routine: \(routine.name)")

                // Convert RoutineExercise → WorkoutExercise
                let workoutExercises = routine.exercises.map { $0.generateWorkoutExercise() }

                // Create active workout
                let activeWorkout = ActiveWorkout(
                    routine: routine,
                    exercises: workoutExercises
                )

                // Store globally
                WorkoutSessionManager.shared.activeWorkout = activeWorkout

                // Navigate to StartRoutine screen
                self.performSegue(withIdentifier: "showStartRoutine", sender: nil)
            }

            return cell

            
        }
    }
    
    
    private func handleCreateCustomRoutine() {
        print("➡️ Create Custom Routine tapped")

        // Navigate to your Create Routine screen
        performSegue(withIdentifier: "showCreateRoutine", sender: nil)
    }

    //as collection view cells not visible->performing segues via code 
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == exploreRoutinesCollectionOutlet {
//            let item = exploreItems[indexPath.item]
//            switch item {
//            case .createCustom:
//                performSegue(withIdentifier: "showCreateRoutine", sender: nil)
//            case .predefined(_):
//                // optional preview
//                break
//            }
//        } else {
//            // Tapped one of "My Routines" cells -> start that routine
//            let routine = WorkoutSessionManager.shared.savedRoutines[indexPath.item]
//            print("🟢 Selected routine to start: \(routine.name)")
//
//            // Convert RoutineExercise -> WorkoutExercise for live tracking
//            let workoutExercises = routine.exercises.map { $0.generateWorkoutExercise() }
//
//            // Build ActiveWorkout and set in manager
//            let active = ActiveWorkout(
//                routine: routine,
//                exercises: workoutExercises
//            )
//            WorkoutSessionManager.shared.activeWorkout = active
//
//            // Perform segue to StartRoutineViewController
//            performSegue(withIdentifier: "showStartRoutine", sender: nil)
//        }
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == exploreRoutinesCollectionOutlet {
            let item = exploreItems[indexPath.item]
            switch item {
            case .createCustom:
                performSegue(withIdentifier: "showCreateRoutine", sender: nil)
            case .predefined(_):
                break
            }
        }

        // DO NOT handle MyRoutines click here!
    }


    override func viewDidLayoutSubviews() {
        [caloriesGoalCard,stepsGoalCard,durationGoalCard].forEach {
            card in
            card.layer.cornerRadius = 16
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.06
            card.layer.shadowOffset = CGSize(width: 0, height: 3)
            card.layer.shadowRadius = 6
            card.layer.masksToBounds = false
            
        }
        emptyMyRoutineOutlet.layer.cornerRadius = 20
        emptyMyRoutineOutlet.layer.borderWidth = 1
        emptyMyRoutineOutlet.layer.borderColor = UIColor.systemGray5.cgColor
    }
    func registerCells() {
        exploreRoutinesCollectionOutlet.register(
            UINib(nibName: "ExploreRoutinesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "explore_routines_cell"
        )

        myRoutinesCollectionOutlet.register(
            UINib(nibName: "MyRoutinesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "my_routines_cell"
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == exploreRoutinesCollectionOutlet {
            // your explore cell size (example)
            return CGSize(width: 160, height: 160)
        } else {
            // my routines card size
            return CGSize(width: 500, height: 100)
        }
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return collectionView == exploreRoutinesCollectionOutlet
    }

    
    
    //to reload the screen for latest routines to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMyRoutinesUI()
    }

    private func updateMyRoutinesUI() {
        let savedCount = WorkoutSessionManager.shared.savedRoutines.count
        myRoutinesCollectionOutlet.isHidden = (savedCount == 0)
        emptyMyRoutineOutlet.isHidden = (savedCount != 0)
        myRoutinesCollectionOutlet.reloadData()
    }

   
    
    
    
    
//    @IBAction func startRoutine1Tapped(_ sender: UIButton) {
//
//        guard let routine = WorkoutSessionManager.shared.savedRoutines.first else {
//                print("❌ No routines found!")
//                return
//            }
//
//            // Convert to live workout exercises
//            let liveExercises = routine.exercises.map { $0.generateWorkoutExercise() }
//
//            WorkoutSessionManager.shared.activeWorkout =
//                ActiveWorkout(routine: routine, exercises: liveExercises)
//
//            performSegue(withIdentifier: "showStartRoutine", sender: nil)
//            }
//            
//            // Helper method to show alerts
//            private func showAlert(title: String, message: String) {
//                let alert = UIAlertController(
//                    title: title,
//                    message: message,
//                    preferredStyle: .alert
//                )
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                present(alert, animated: true)
//            }
//            
//            // Optional: Add this to help with debugging
//            override func viewWillAppear(_ animated: Bool) {
//                super.viewWillAppear(animated)
//                
//                // Print current state when screen appears
//                print("=== WORKOUT HOME APPEARED ===")
//                print("📊 Saved routines: \(WorkoutSessionManager.shared.savedRoutines.count)")
//                
//                for (index, routine) in WorkoutSessionManager.shared.savedRoutines.enumerated() {
//                    print("  [\(index)] \(routine.name) - \(routine.exercises.count) exercises")
//                }
//            }
      }

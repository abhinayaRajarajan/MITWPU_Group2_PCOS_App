//
//  MuscleTypeSelectionViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class MuscleTypeSelectionViewController: UIViewController {

    @IBOutlet weak var targettedMuscleTableView: UITableView!
    
    private let allMuscles=MuscleGroup.allCases
    var selectedMuscles:Set<MuscleGroup> = []
    var onSave:((Set<MuscleGroup>)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set "All Muscles" as default if nothing is selected
                if selectedMuscles.isEmpty {
                    selectedMuscles.insert(.allMuscles)
                }
        setupUI()
        
    }
    private func setupUI(){
        title = "Select Muscles"
        targettedMuscleTableView.delegate=self
        targettedMuscleTableView.dataSource=self
        //targettedMuscleTableView.register(UITableViewCell.self, forCellReuseIdentifier: "muscle_cell")
        targettedMuscleTableView.allowsMultipleSelection = true
    }
    
    @IBAction func muscleCloseButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func muscleSaveButtonTapped(_ sender: UIBarButtonItem) {
        onSave?(selectedMuscles)
        dismiss(animated: true)
    }
}//class closed
extension MuscleTypeSelectionViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allMuscles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "muscle_cell",
            for: indexPath
        ) as? MuscleTypeSelectionTableViewCell else {
            return UITableViewCell()
        }

        
        let muscle=allMuscles[indexPath.row]
        
        cell.muscleTypeLabel.text = muscle.displayName

        
        if selectedMuscles.contains(muscle){
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        let imageName = muscle.displayImage
        if !imageName.isEmpty {
            cell.muscleTypeImageView.image = UIImage(named: imageName)
        } else {
            cell.muscleTypeImageView.image = nil // or a placeholder image
        }
        
        return cell
    }
}
extension MuscleTypeSelectionViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let muscle = allMuscles[indexPath.row]
        
        // Check if "All Muscles" is being selected
        if muscle == .allMuscles {
            // If All Muscle is tapped and already selected, deselect it
            if selectedMuscles.contains(.allMuscles) {
                selectedMuscles.remove(.allMuscles)
            } else {
                // Clear all other selections and select only "All Muscles"
                selectedMuscles.removeAll()
                selectedMuscles.insert(.allMuscles)
            }
            // Reload entire table to update all checkmarks
            tableView.reloadData()
        } else {
            // User is selecting a specific Muscle type
            
            // If "All Muscles" is currently selected, remove it first
            if selectedMuscles.contains(.allMuscles) {
                selectedMuscles.remove(.allMuscles)
                // Reload the "All Muscles" row to remove its checkmark
                if let allIndex = allMuscles.firstIndex(of: .allMuscles) {
                    tableView.reloadRows(at: [IndexPath(row: allIndex, section: 0)], with: .automatic)
                }
            }
            
            // Toggle the selected Muscle
            if selectedMuscles.contains(muscle){
                selectedMuscles.remove(muscle)
            }
            else {
                selectedMuscles.insert(muscle)
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}


    


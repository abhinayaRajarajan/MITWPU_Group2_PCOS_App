//
//  EquipmentSelectionViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EquipmentSelectionViewController: UIViewController {

    @IBOutlet weak var equipmentTableView: UITableView!
    
    private let allEquipment = Equipment.allCases
    
    var selectedEquipment: Set<Equipment> = []
    var onSave: ((Set<Equipment>) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set "All Equipment" as default if nothing is selected
                if selectedEquipment.isEmpty {
                    selectedEquipment.insert(.allEquipment)
                }
        
        setupUI()
        
    }
    private func setupUI(){
        title = "Select Equipment"
        equipmentTableView.delegate = self
        equipmentTableView.dataSource = self
        equipmentTableView.allowsMultipleSelection = true
        //when changed to false no change was visble
    }
    
    @IBAction func equipmentCloseButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func equipmentSaveButtonTapped(_ sender: UIBarButtonItem) {
        onSave?(selectedEquipment)
        dismiss(animated: true)
    }
}//class closed
extension EquipmentSelectionViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allEquipment.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "equipment_cell", for: indexPath) as? EquipmentSelectionTableViewCell else {
            return UITableViewCell()
        }
        
        let equipment = allEquipment[indexPath.row]
        
        cell.equipmentNameLabel.text = equipment.displayName
        if selectedEquipment.contains(equipment){
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        // displayImage is a non-optional String; just check emptiness
        let imageName = equipment.displayImage
        if !imageName.isEmpty {
            cell.equipmentImageView.image = UIImage(named: imageName)
        } else {
            cell.equipmentImageView.image = nil // or a placeholder image
        }
        
        return cell
    }
}
extension EquipmentSelectionViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let equipment = allEquipment[indexPath.row]
            
            // Check if "All Equipment" is being selected
            if equipment == .allEquipment {
                // If All Equipment is tapped and already selected, deselect it
                if selectedEquipment.contains(.allEquipment) {
                    selectedEquipment.remove(.allEquipment)
                } else {
                    // Clear all other selections and select only "All Equipment"
                    selectedEquipment.removeAll()
                    selectedEquipment.insert(.allEquipment)
                }
                // Reload entire table to update all checkmarks
                tableView.reloadData()
            } else {
                // User is selecting a specific equipment type
                
                // If "All Equipment" is currently selected, remove it first
                if selectedEquipment.contains(.allEquipment) {
                    selectedEquipment.remove(.allEquipment)
                    // Reload the "All Equipment" row to remove its checkmark
                    if let allIndex = allEquipment.firstIndex(of: .allEquipment) {
                        tableView.reloadRows(at: [IndexPath(row: allIndex, section: 0)], with: .automatic)
                    }
                }
                
                // Toggle the selected equipment
                if selectedEquipment.contains(equipment){
                    selectedEquipment.remove(equipment)
                }
                else {
                    selectedEquipment.insert(equipment)
                }
                
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
}

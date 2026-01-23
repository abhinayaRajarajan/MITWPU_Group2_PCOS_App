//
//  DietViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class DietViewController: UIViewController {

    var todaysFoods: [Food] = [] //sks: to filter food for today
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var AddMealButton: UIButton!
    private var headerView: NutritionHeader?

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Diet"
            navigationController?.navigationBar.prefersLargeTitles = true
            setupNavigation()
            setupTableView()
            setupAddButtonStyle()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.navigationBar.prefersLargeTitles = true
            filterTodaysFoods()
            for i in FoodLogDataSource.todaysMeal {
                print(i.name)
            }
        }

        // MARK: - Setup Helpers
        private func setupNavigation() {
            let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarTapped))
            navigationItem.rightBarButtonItem = calendar
        }

        private func setupTableView() {
            tableView.register(LogsTableViewCell.nib(), forCellReuseIdentifier: LogsTableViewCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = 100
            tableView.separatorStyle = .singleLine
            tableView.register(NutritionHeader.nib(), forHeaderFooterViewReuseIdentifier: NutritionHeader.identifier)
            tableView.separatorStyle = .none
            tableView.register(NoFoodTableViewCell.nib(), forCellReuseIdentifier: NoFoodTableViewCell.identifier)
        }

        private func setupAddButtonStyle() {
            AddMealButton.backgroundColor = UIColor.systemPink
            AddMealButton.setTitle("Add", for: .normal)
            AddMealButton.setTitleColor(.white, for: .normal)
            AddMealButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            AddMealButton.layer.cornerRadius = 25
            AddMealButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        }

        // MARK: - Actions
        @objc func calendarTapped() {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "dietLogs") as? DietCalendarLogsViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        }

           @IBAction func addButtonTapped(_ sender: UIButton) {
               let storyboard = UIStoryboard(name: "Diet", bundle: nil)
                   guard let addVC = storyboard.instantiateViewController(withIdentifier: "AddMealViewController") as? AddMealViewController else {
                       let addVC = AddMealViewController()
                       addVC.delegate = self
                       addVC.dietDelegate = self  // Add this line
                       navigationController?.pushViewController(addVC, animated: true)
                       return
                   }
                   addVC.delegate = self
                   addVC.dietDelegate = self  // Add this line
                   navigationController?.pushViewController(addVC, animated: true)
           }

 
    // MARK: - Data / Filtering
    private func filterTodaysFoods() {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        let allFoods = FoodLogDataSource.sampleFoods
        todaysFoods = allFoods.filter { food in
            food.timeStamp >= startOfToday && food.timeStamp < startOfTomorrow
        }
        todaysFoods.sort { $0.timeStamp > $1.timeStamp }
        tableView.reloadData()
        print("DietVC — found \(todaysFoods.count) foods for today")
    }
    
    // MARK: - Delete Meal
    private func deleteMeal(at indexPath: IndexPath) {
        let mealToDelete = todaysFoods[indexPath.row]
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Meal",
            message: "Are you sure you want to delete '\(mealToDelete.name)'?",
            preferredStyle: .alert
        )
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Delete cancelled")
        }
        
        // Delete action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            print("🗑️ Deleting meal: \(mealToDelete.name)")
            
            self.headerView?.subtractValues(mealToDelete)
            FoodLogDataSource.removeFood(mealToDelete)
            self.todaysFoods.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            print("Meal deleted successfully")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
}


extension DietViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysFoods.isEmpty ? 1 : todaysFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if todaysFoods.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoFoodTableViewCell.identifier, for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LogsTableViewCell.identifier, for: indexPath) as! LogsTableViewCell
        let item = todaysFoods[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !todaysFoods.isEmpty else { return }
        
        let selectedFood = todaysFoods[indexPath.row]
        print("🔍 Selected food: \(selectedFood.name)")
        FoodLogIngredientViewController.present(from: self, with: selectedFood)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NutritionHeader.identifier) as! NutritionHeader
        header.configure()
        header.delegate = self 
        self.headerView = header
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        250
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return todaysFoods.isEmpty ? UITableView.automaticDimension : 100
    }
    

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !todaysFoods.isEmpty
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        guard !todaysFoods.isEmpty else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteMeal(at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}


extension DietViewController: AddMealDelegate {
    func didAddMeal(_ food: Food) {
        FoodLogDataSource.addFoodBarCode(food)

        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        if food.timeStamp >= startOfToday && food.timeStamp < startOfTomorrow {
            headerView?.updateValues(food)
        }

        filterTodaysFoods()
        print("Added food: \(food.name)")
    }
}


extension DietViewController: AddDescribedMealDelegate {
    func didConfirmMeal(_ food: Food) {
        print("🎉 didConfirmMeal called with: \(food.name)")
        
        FoodLogDataSource.addFoodBarCode(food)
        
        if presentedViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
        
        filterTodaysFoods()
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        if food.timeStamp >= startOfToday && food.timeStamp < startOfTomorrow {
            headerView?.updateValues(food)
        }
        
        print("Meal added successfully")
    }
}

extension DietViewController: NutritionHeaderDelegate {
    func didTapProteinView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let chartVC = storyboard.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            chartVC.macroType = .protein
            navigationController?.pushViewController(chartVC, animated: true)
        }
    }
    
    func didTapCarbsView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let chartVC = storyboard.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            chartVC.macroType = .carbs
            navigationController?.pushViewController(chartVC, animated: true)
        }
    }
    
    func didTapFatsView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let chartVC = storyboard.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            chartVC.macroType = .fats
            navigationController?.pushViewController(chartVC, animated: true)
        }
    }
}

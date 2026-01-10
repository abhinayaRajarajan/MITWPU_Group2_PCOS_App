//
//  DietViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class DietViewController: UIViewController {

    var todaysFoods: [Food] = [] //sks: to filter food for today
    
    var dummyData = FoodLogDataSource.sampleFoods
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
               filterTodaysFoods()
           }

           //Setup Helpers
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
           }

           private func setupAddButtonStyle() {
               AddMealButton.backgroundColor = UIColor.systemPink
               AddMealButton.setTitle("Add", for: .normal)
               AddMealButton.setTitleColor(.white, for: .normal)
               AddMealButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
               AddMealButton.layer.cornerRadius = 25
               AddMealButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
           }


           //Actions
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
                   navigationController?.pushViewController(addVC, animated: true)
                   return
               }
               addVC.delegate = self
               navigationController?.pushViewController(addVC, animated: true)
           }

           //Data / Filtering
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
       }


//UITableView DataSource & Delegate
extension DietViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LogsTableViewCell.identifier, for: indexPath) as! LogsTableViewCell
        let item = todaysFoods[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    //Handle Row Selection (THIS IS THE KEY METHOD)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedFood = todaysFoods[indexPath.row]
        print("🔍 Selected food: \(selectedFood.name)")
        FoodLogIngredientViewController.present(from: self, with: selectedFood)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NutritionHeader.identifier) as! NutritionHeader
        headerView.configure()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        250
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        
//    }
}

// MARK: - AddMeal Delegate
extension DietViewController: AddMealDelegate {
    func didAddMeal(_ food: Food) {
        // Save to data source
        FoodLogDataSource.addFoodBarCode(food)

        // If the added meal is today, incrementally update the header
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        if food.timeStamp >= startOfToday && food.timeStamp < startOfTomorrow {
            headerView?.updateValues(food)
        }

        // Refresh list
        filterTodaysFoods()
        print("Added food: \(food.name)")
    }
}


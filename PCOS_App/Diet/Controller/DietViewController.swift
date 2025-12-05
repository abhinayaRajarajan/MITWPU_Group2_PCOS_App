//
//  DietViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class DietViewController: UIViewController {

    var dummyData = DataStore.sampleFoods
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diet"
        navigationController?.navigationBar.prefersLargeTitles = true
        let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarTapped))
        navigationItem.rightBarButtonItem = calendar
        
        let header = Bundle.main.loadNibNamed("NutritionHeader", owner: self, options: nil)?.first as! NutritionHeader
        tableView.tableHeaderView = header
        header.frame.size.height = 200
        tableView.register(LogsTableViewCell.nib(), forCellReuseIdentifier: LogsTableViewCell.identifier)
        tableView.register(NutritionTableViewCell.nib(), forCellReuseIdentifier: NutritionTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func calendarTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "dietLogs") as? DietCalendarLogsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension DietViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dummyData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NutritionTableViewCell.identifier) as! NutritionTableViewCell
            return cell
        }
        
  
        let cell = tableView.dequeueReusableCell(withIdentifier: LogsTableViewCell.identifier, for: indexPath) as! LogsTableViewCell
        let dataIndex = indexPath.row - 1
        let item = dummyData[dataIndex]
        cell.configure(with: item)
        
//        cell.foodName.text = item.name
//        cell.calories.text = "\(Int(item.calories))kcal"
//        cell.foodName.font = UIFont.systemFont(ofSize: 15, weight: .bold)
//        cell.carbs.text = "\(Int(item.carbsContent))g"
//        cell.protein.text = "\(Int(item.proteinContent))g"
//        cell.fats.text = "\(Int(item.fatsContent))g"
//        
//        cell.foodImg.image = UIImage(named: "biryani")
//        cell.foodImg.layer.cornerRadius = 10
//        cell.foodImg.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250
        }
        return 100
    }
}

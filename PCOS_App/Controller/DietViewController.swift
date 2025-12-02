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
        
        
        let nib = UINib(nibName: "LogsTableViewCell", bundle: nil)
        tableView.register(LogsTableViewCell.nib(), forCellReuseIdentifier: "LogsTableViewCell")
        tableView.register(NutritionTableViewCell.nib(), forCellReuseIdentifier: "NutritionTableViewCell")
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
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionTableViewCell") as! NutritionTableViewCell
//            return cell
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogsTableViewCell", for: indexPath) as! LogsTableViewCell
        cell.foodName.text = dummyData[indexPath.row].name
        cell.calories.text = "\(dummyData[indexPath.row].calories)kcal"
        cell.foodName.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        cell.carbs.text = "\(dummyData[indexPath.row].carbsContent)g"
        cell.protein.text = "\(dummyData[indexPath.row].proteinContent)g"
        cell.fats.text = "\(dummyData[indexPath.row].fatsContent)g"
        cell.imageView?.image = UIImage(named: "biryani")
        cell.imageView?.layer.cornerRadius = 10
        return cell
    }
        
}

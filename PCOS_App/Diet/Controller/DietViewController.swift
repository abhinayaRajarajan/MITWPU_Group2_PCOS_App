//
//  DietViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class DietViewController: UIViewController {
//<<<<<<< HEAD
//
//    var dummyData = DataStore.sampleFoods
//    @IBOutlet weak var tableView: UITableView!
//    
//=======
    
    var dummyData = DataStore.sampleFoods
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var AddMealButton: UIButton!
    
//>>>>>>> f5227e3 (Sync folder structure with remote)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diet"
        navigationController?.navigationBar.prefersLargeTitles = true
        let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarTapped))
        navigationItem.rightBarButtonItem = calendar
        
//<<<<<<< HEAD
        let header = Bundle.main.loadNibNamed("NutritionHeader", owner: self, options: nil)?.first as! NutritionHeader
        tableView.tableHeaderView = header
        header.configure()
        header.frame.size.height = 380
        tableView.register(LogsTableViewCell.nib(), forCellReuseIdentifier: LogsTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
//=======
//        
//        _ = UINib(nibName: "LogsTableViewCell", bundle: nil)
//        tableView.register(LogsTableViewCell.nib(), forCellReuseIdentifier: "LogsTableViewCell")
//        tableView.dataSource = self
//        tableView.delegate = self
        
        setupAddButton()
        AddMealButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupAddButton() {
        AddMealButton.backgroundColor = UIColor.systemPink
        AddMealButton.setTitle("Add", for: .normal)
        AddMealButton.setTitleColor(.white, for: .normal)
        AddMealButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        AddMealButton.layer.cornerRadius = 25
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        AddMealViewController.present(from: self)
//>>>>>>> f5227e3 (Sync folder structure with remote)
    }
    
    @objc func calendarTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "dietLogs") as? DietCalendarLogsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//<<<<<<< HEAD
extension DietViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: LogsTableViewCell.identifier, for: indexPath) as! LogsTableViewCell
        let dataIndex = indexPath.row
        let item = dummyData[dataIndex]
        cell.configure(with: item)
//=======
//
//
//extension DietViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dummyData.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "LogsTableViewCell", for: indexPath) as! LogsTableViewCell
//        cell.foodName.text = dummyData[indexPath.row].name
//        cell.calories.text = "\(dummyData[indexPath.row].calories)kcal"
//        cell.foodName.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        cell.carbs.text = "\(dummyData[indexPath.row].carbsContent)g"
//        cell.protein.text = "\(dummyData[indexPath.row].proteinContent)g"
//        cell.fats.text = "\(dummyData[indexPath.row].fatsContent)g"
//        cell.imageView?.image = UIImage(named: "biryani")
//        cell.imageView?.layer.cornerRadius = 10
//>>>>>>> f5227e3 (Sync folder structure with remote)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Today's Logs"
    }
    
}

extension DietViewController {
    func createAddButtonProgrammatically() {
        let addButton = UIButton(type: .system)
        addButton.backgroundColor = UIColor(hex:"fe7a96")
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        addButton.layer.cornerRadius = 25
        addButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            addButton.widthAnchor.constraint(equalToConstant: 100),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        addButton.addTarget(self, action: #selector(addButtonTappedProgrammatic), for: .touchUpInside)
    }

    @objc private func addButtonTappedProgrammatic() {
        AddMealViewController.present(from: self)
//>>>>>>> f5227e3 (Sync folder structure with remote)
    }
}

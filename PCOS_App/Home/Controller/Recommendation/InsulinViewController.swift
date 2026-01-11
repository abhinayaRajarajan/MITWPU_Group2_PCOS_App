//
//  InsulinViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class InsulinViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var recommendation: Recommendation?
    
    @IBOutlet weak var warningcard: UIView!
    @IBOutlet weak var InsulinSummaryCardView: UIView!
    private var highSugarFoods: [InsulinFoodItem] = []
        
    @IBOutlet weak var summaryCardView: InsulinSummaryCardView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        if let rec = recommendation {
                    print("Insulin recommendation: \(rec.title)")
                    title = rec.title  // Set the title from recommendation
                }
            
        warningcard.layer.cornerRadius=20
        
        summaryCardView.layer.cornerRadius=20
        
            setupSampleData()
            setupTableView()
            setupSummaryCard()
        }
    private func setupSummaryCard() {
            // Configure with your data
            summaryCardView.configure(high: 3, moderate: 2, low: 5)
        }
        private func setupSampleData() {
            highSugarFoods = [
                InsulinFoodItem(
                    name: "Chocolate Cake",
                    image: "🍰",
                    sugarContent: "High",
                    day: "Monday",
                    description: "Rich chocolate cake with frosting"
                ),
                InsulinFoodItem(
                    name: "Rasgulla",
                    image: "🍡",
                    sugarContent: "Very High",
                    day: "Wednesday",
                    description: "Sweet Indian cottage cheese balls in syrup"
                ),
                InsulinFoodItem(
                    name: "Ice Cream",
                    image: "🍨",
                    sugarContent: "High",
                    day: "Friday",
                    description: "Creamy vanilla ice cream"
                )
            ]
        }

        private func setupTableView() {
            // Register the cell
            tableView.register(UINib(nibName: "InsulinFoodTableViewCell", bundle: nil),
                              forCellReuseIdentifier: "InsulinFoodTableViewCell")
            
            tableView.dataSource = self
            tableView.delegate = self
            
            // Set up table view properties
            //tableView.estimatedRowHeight = 120
            tableView.rowHeight = UITableView.automaticDimension
            tableView.separatorStyle = .none
            //tableView.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 0.1)
            
            // Add padding
            tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        }
    }

    // MARK: - UITableView DataSource & Delegate
    extension InsulinViewController: UITableViewDataSource, UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return highSugarFoods.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InsulinFoodTableViewCell", for: indexPath) as! InsulinFoodTableViewCell
                let item = highSugarFoods[indexPath.row]
                cell.configure(with: item)  // This should work now
                return cell
            }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120
        }
        
        // Handle Row Selection
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let selectedFood = highSugarFoods[indexPath.row]
            
            // Show alert or navigate to detail screen
            showFoodDetail(for: selectedFood)
        }
        
        private func showFoodDetail(for food: InsulinFoodItem) {
            let alert = UIAlertController(
                title: food.name,
                message: "\(food.description)\nDay: \(food.day)\nSugar Level: \(food.sugarContent)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - FoodItem Model
    struct InsulinFoodItem {
        let name: String
        let image: String  // Can be emoji or image name
        let sugarContent: String
        let day: String
        let description: String
    }

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
    
    @IBOutlet weak var InfoCard: UIView!
    @IBOutlet weak var summaryCardView: InsulinSummaryCardView!
    
    @IBOutlet weak var ReasoningCard: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let rec = recommendation {
            print("Insulin recommendation: \(rec.title)")
            title = rec.title  // Set the title from recommendation
        }
        
        warningcard.layer.cornerRadius=15
        
        summaryCardView.layer.cornerRadius=20
        InfoCard.layer.cornerRadius=20
        ReasoningCard.layer.cornerRadius=20
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
                image: "ChocolateCake",
                sugarContent: "High",
                day: "Monday",
                description: "Rich chocolate cake with frosting"
            ),
            InsulinFoodItem(
                name: "Rasgulla",
                image: "Rasgulla",
                sugarContent: "Very High",
                day: "Wednesday",
                description: "Sweet Indian cottage cheese balls in syrup"
            ),
            InsulinFoodItem(
                name: "Ice Cream",
                image: "Icecream",
                sugarContent: "High",
                day: "Friday",
                description: "Creamy vanilla ice cream"
            )
        ]
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "InsulinFoodTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "InsulinFoodTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        //tableView.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 0.1)
        
        // Add padding
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    @IBAction func openLinkTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://www.mayoclinic.org/diseases-conditions/pcos/symptoms-causes/syc-20353439") else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

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
    }
}

struct InsulinFoodItem {
    let name: String
    let image: String
    let sugarContent: String
    let day: String
    let description: String
}

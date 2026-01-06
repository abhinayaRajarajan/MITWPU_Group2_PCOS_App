//
//  HomeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var symptomsCollectionView: UICollectionView!
    @IBOutlet weak var recommendationsTableView: UITableView!
    
    // Storing selected symptoms
    private var selectedSymptoms: [LoggedSymptoms] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = UIColor(red: 1.0, green: 0.94, blue: 0.96, alpha: 1.0)
        
        symptomsCollectionView.backgroundColor = UIColor(red: 1.0, green: 0.94, blue: 0.96, alpha: 1.0)

        let profile = UIBarButtonItem(image:UIImage(systemName:"person.circle"), style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = profile
        
        //        // Make sure LogButton is added to view and visible
        //        view.addSubview(LogButton)
        //        LogButton.translatesAutoresizingMaskIntoConstraints = false
        //        NSLayoutConstraint.activate([
        //            LogButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //            LogButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        //        ])
        
        
        // Just assign delegate and dataSource (or you already connected in Storyboard)
        symptomsCollectionView.delegate = self
        symptomsCollectionView.dataSource = self
        
        setupRecommendationsTableView()
        
        loadTodaysSymptoms()
        
    }
    
    private func setupRecommendationsTableView() {
        recommendationsTableView.register(UINib(nibName: "RecommendationsTableViewCell", bundle: nil), forCellReuseIdentifier: "RecommendationsTableViewCell")
        
        // Set delegate and dataSource
            recommendationsTableView.delegate = self
            recommendationsTableView.dataSource = self
            
            // Configure table view
            //recommendationsTableView.rowHeight = UITableView.automaticDimension
            //recommendationsTableView.rowHeight = 140
            //recommendationsTableView.estimatedRowHeight = 100
            recommendationsTableView.separatorStyle = .none
            recommendationsTableView.backgroundColor = .clear
        
        recommendationsTableView.separatorStyle = .singleLine
        recommendationsTableView.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        recommendationsTableView.separatorColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload symptoms when coming back from logger
        loadTodaysSymptoms()
    }
    
    private func loadTodaysSymptoms() {
        // Load saved symptoms from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "todaysSymptoms"),
       let symptoms = try? JSONDecoder().decode([LoggedSymptoms].self, from: data) {
        selectedSymptoms = symptoms
        symptomsCollectionView.reloadData()        }
    }
    
    @objc func addTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    @IBAction func logButtonTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "showSymptomLogger", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSymptomLogger" {
            if let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
                
                // Pre-select existing symptoms
                symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
                
                // Handle callback when symptoms are selected
                symptomLoggerVC.onSymptomsSelected = { [weak self] (symptoms: [LoggedSymptoms]) in
                    self?.selectedSymptoms = symptoms
                    
                    // Save to UserDefaults
                    if let encoded = try? JSONEncoder().encode(symptoms) {
                        UserDefaults.standard.set(encoded, forKey: "todaysSymptoms")
                    }
                    
                    // Reload collection view
                    self?.symptomsCollectionView.reloadData()
                }
            }
        }
        }
        
    
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedSymptoms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SymptomItemCollectionViewCell.identifier, for: indexPath) as! SymptomItemCollectionViewCell
        
        let symptom = selectedSymptoms[indexPath.item]
        
        // Convert LoggedSymptoms to SymptomItem for the cell
        let symptomItem = SymptomItem(name: symptom.name, icon: symptom.icon, isSelected: false)
        cell.configure(with: symptomItem, isSelected: false)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showSymptomLogger", sender: self)
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationsTableViewCell", for: indexPath) as! RecommendationsTableViewCell
        
        let recommendation = recommendations[indexPath.row]
        cell.configure(with: recommendation)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recommendation = recommendations[indexPath.row]
        
        // Handle navigation based on recommendation
        print("Tapped: \(recommendation.title)")
        
        // You can add navigation logic here
        // For example:
        // if let navigationTarget = recommendation.navigationTarget {
        //     // Navigate to specific screen
        // }
    }
}

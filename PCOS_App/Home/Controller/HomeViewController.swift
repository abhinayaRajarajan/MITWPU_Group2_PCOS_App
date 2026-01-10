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
        let profile = UIBarButtonItem(image:UIImage(systemName:"person.fill"), style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = profile
        
        let calendar = UIBarButtonItem(image:UIImage(systemName:"calendar.fill"), style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = calendar
        
        
        
        view.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 0.1)
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
        
        
        loadTodaysSymptoms()
        
        setupRecommendationsTableView()
        
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
        recommendationsTableView.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 0.1)
        
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
        // Handle symptom logger segue
        if segue.identifier == "showSymptomLogger" {
            if let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
                symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
                symptomLoggerVC.onSymptomsSelected = { [weak self] (symptoms: [LoggedSymptoms]) in
                    self?.selectedSymptoms = symptoms
                    if let encoded = try? JSONEncoder().encode(symptoms) {
                        UserDefaults.standard.set(encoded, forKey: "todaysSymptoms")
                    }
                    self?.symptomsCollectionView.reloadData()
                }
            }
            return // Exit early
        }
        
        // Handle recommendation segues
        guard let recommendation = sender as? Recommendation else { return }
        
        switch segue.identifier {
        case "showProtein":
            if let proteinVC = segue.destination as? ProteinViewController {
                proteinVC.recommendation = recommendation
            }
            
        case "showWorkoutPush":
            if let workoutVC = segue.destination as? WorkoutPushViewController {
                workoutVC.recommendation = recommendation
            }
            
        case "showInsulin":
            if let insulinVC = segue.destination as? InsulinViewController {
                insulinVC.recommendation = recommendation
            }
            
        default:
            break
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recommendation = recommendations[indexPath.row]
        
        print("Tapped: \(recommendation.title)")
        
        // Navigate based on category with CORRECT segue identifiers
        switch recommendation.category {
        case .nutrition:
            performSegue(withIdentifier: "showProtein", sender: recommendation)
            
        case .workout:
            performSegue(withIdentifier: "showWorkoutPush", sender: recommendation)
            
        case .foodPattern:
            performSegue(withIdentifier: "showInsulin", sender: recommendation)
            
        default:
            performSegue(withIdentifier: "showDetail", sender: recommendation)
        }
    }
    
    
        
        
    }

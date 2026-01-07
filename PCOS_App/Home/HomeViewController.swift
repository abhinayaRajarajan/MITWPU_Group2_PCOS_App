//
//  HomeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var symptomsCollectionView: UICollectionView!
    
    @IBOutlet weak var headerCollectionView: UICollectionView!
    // Storing selected symptoms
    private var selectedSymptoms: [LoggedSymptoms] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        title = "Hi Priya"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let profile = UIBarButtonItem(image:UIImage(systemName:"person.circle"), style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = profile
        
        headerCollectionView.dataSource = self
        headerCollectionView.delegate = self
        
        registerCells()
        
    }
    func registerCells() {
        headerCollectionView.register(
            UINib(
                nibName: "HomeHeaderCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "home_header")
    }
    @objc func addTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_header", for: indexPath) as! HomeHeaderCollectionViewCell
        // Any specific data setup for Priya can go here
        return cell
    }
    
    // 4. Define the size of your header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // This makes the cell take up about 45% of the screen height
        return CGSize(width: collectionView.frame.width, height: view.frame.height * 0.45)
    }
}


//        let profile = UIBarButtonItem(image:UIImage(systemName:"person.circle"), style: .plain, target: self, action: #selector(addTapped))
//        navigationItem.rightBarButtonItem = profile


// Just assign delegate and dataSource (or you already connected in Storyboard)
//        symptomsCollectionView.delegate = self
//        symptomsCollectionView.dataSource = self

//loadTodaysSymptoms()

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Reload symptoms when coming back from logger
//        loadTodaysSymptoms()
//    }
//
//    private func loadTodaysSymptoms() {
//        // Load saved symptoms from UserDefaults
//        if let data = UserDefaults.standard.data(forKey: "todaysSymptoms"),
//       let symptoms = try? JSONDecoder().decode([LoggedSymptoms].self, from: data) {
//        selectedSymptoms = symptoms
//        symptomsCollectionView.reloadData()        }
//    }
//
//
//    }
//
////    @IBAction func logButtonTapped(_ sender: UIButton) {
////        performSegue(withIdentifier: "showSymptomLogger", sender: self)
////    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showSymptomLogger" {
//            if let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
//
//                // Pre-select existing symptoms
//                symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
//
//                // Handle callback when symptoms are selected
//                symptomLoggerVC.onSymptomsSelected = { [weak self] (symptoms: [LoggedSymptoms]) in
//                    self?.selectedSymptoms = symptoms
//
//                    // Save to UserDefaults
//                    if let encoded = try? JSONEncoder().encode(symptoms) {
//                        UserDefaults.standard.set(encoded, forKey: "todaysSymptoms")
//                    }
//
//                    // Reload collection view
//                    self?.symptomsCollectionView.reloadData()
//                }
//            }
//        }
//        }
//
//
//}
//
//// MARK: - UICollectionViewDataSource
//extension HomeViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return selectedSymptoms.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SymptomItemCollectionViewCell.identifier, for: indexPath) as! SymptomItemCollectionViewCell
//
//        let symptom = selectedSymptoms[indexPath.item]
//
//        // Convert LoggedSymptoms to SymptomItem for the cell
//        let symptomItem = SymptomItem(name: symptom.name, icon: symptom.icon, isSelected: false)
//        cell.configure(with: symptomItem, isSelected: false)
//
//        return cell
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension HomeViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        performSegue(withIdentifier: "showSymptomLogger", sender: self)
//    }
//}

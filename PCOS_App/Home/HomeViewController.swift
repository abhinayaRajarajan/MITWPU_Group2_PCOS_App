//
//  HomeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController, DataPassDelegate {
    func passData(symptoms: [SymptomItem]) -> [SymptomItem] {
        self.selectedSymptoms += symptoms
        // Save with today's date key
        let todaysKey = self.getTodaysKey()
        if let encoded = try? JSONEncoder().encode(symptoms) {
            UserDefaults.standard.set(encoded, forKey: todaysKey)
        }
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        return symptoms
    }
    
    
   
   
    @IBOutlet weak var collectionView: UICollectionView!
    // Storing selected symptoms
    private var selectedSymptoms: [SymptomItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        title = "Today"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let bgColor = UIColor(hex: "#FCEEED")
            collectionView.backgroundColor = bgColor
            view.backgroundColor = bgColor
        
        let calendar = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )

        let profile = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )

        navigationItem.rightBarButtonItems = [profile, calendar]

        registerCells()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\nThis is HomeVC:",selectedSymptoms)
    }
    private func loadTodaysSymptoms() {
        if let data = UserDefaults.standard.data(forKey: "todaysSymptoms"),
           let symptoms = try? JSONDecoder().decode([SymptomItem].self, from: data) {
            
            // Check if symptoms are from today
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Filter only symptoms logged today
            let todaysSymptoms = symptoms.filter { symptom in
                let symptomDate = calendar.startOfDay(for: symptom.date!)
                return symptomDate == today
            }
            
            selectedSymptoms = todaysSymptoms
            
            // Update UserDefaults with filtered symptoms
            if let encoded = try? JSONEncoder().encode(todaysSymptoms) {
                UserDefaults.standard.set(encoded, forKey: "todaysSymptoms")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    func registerCells() {
        collectionView.register(
            UINib(nibName: "HomeHeaderCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "home_header"
        )

        collectionView.register(
            UINib(nibName: "AddSymptomCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "AddSymptomCollectionViewCell"
        )

        collectionView.register(
            UINib(nibName: "SymptomItemCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: SymptomItemCollectionViewCell.identifier
        )
    }

    @objc func addTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createHomeHeaderSection()
            case 1: return self.createSymptomSection()
            default:
                return nil
            }
        }
    }
    
    func createHomeHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(500))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }
}


extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return selectedSymptoms.count + 1
            default:
                return 0
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_header", for: indexPath) as! HomeHeaderCollectionViewCell
            return cell
        }
        else{
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSymptomCollectionViewCell", for: indexPath) as! AddSymptomCollectionViewCell
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomItemCollectionViewCell", for: indexPath) as! SymptomItemCollectionViewCell
            let symptom = selectedSymptoms[indexPath.item - 1]
            let isSelected = true
            cell.configure(with: symptom, isSelected: isSelected)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard indexPath.section == 1 else { return }

        if indexPath.item == 0 {
            performSegue(withIdentifier: "showSymptomLogger", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSymptomLogger",
           let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
            
            symptomLoggerVC.delegate = self

            symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)

            symptomLoggerVC.onSymptomsSelected = { [weak self] symptoms in
                guard let self = self else { return }

                self.selectedSymptoms = symptoms

                // Save with today's date key
                let todaysKey = self.getTodaysKey()
                if let encoded = try? JSONEncoder().encode(symptoms) {
                    UserDefaults.standard.set(encoded, forKey: todaysKey)
                }

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    // Helper to get today's key
    private func getTodaysKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "symptoms_\(formatter.string(from: Date()))"
    }

    

    func createSymptomSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(100)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .absolute(100)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16, leading: 20, bottom: 16, trailing: 20
        )
        section.orthogonalScrollingBehavior = .continuous


        return section
    }

    

}


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


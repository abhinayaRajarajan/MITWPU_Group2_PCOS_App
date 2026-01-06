//
//  HomeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var symptomsCollectionView: UICollectionView!
    @IBOutlet weak var weekCalendarContainer: UIView!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    
    let weekCalendar = WeekCalendarView()
        var currentSelectedDate = Date()
        
        // Storing selected symptoms
        private var selectedSymptoms: [LoggedSymptoms] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set title
            title = "Home"
            navigationController?.navigationBar.prefersLargeTitles = true
            let profile = UIBarButtonItem(
                image: UIImage(systemName: "person.circle"),
                style: .plain,
                target: self,
                action: #selector(addTapped)
            )
            navigationItem.rightBarButtonItem = profile
            
            // Setup collection views
            symptomsCollectionView.delegate = self
            symptomsCollectionView.dataSource = self
            
            setupWeekCalendar()
            loadSymptomsForDate(Date())
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadSymptomsForDate(currentSelectedDate)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // Update frame when layout changes
            weekCalendar.frame = weekCalendarContainer.bounds
            
            print("📐 viewDidLayoutSubviews:")
            print("   Container bounds: \(weekCalendarContainer.bounds)")
            print("   Calendar frame: \(weekCalendar.frame)")
            
            if weekCalendar.frame.size.width > 0 {
                weekCalendar.layoutSubviews()
            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            print("After layout - container frame: \(weekCalendarContainer.frame)")
            print("After layout - calendar frame: \(weekCalendar.frame)")
        }
        
        private func setupWeekCalendar() {
            print("🔵 Setting up week calendar...")
            
            // Use manual frame layout instead of Auto Layout
            weekCalendar.translatesAutoresizingMaskIntoConstraints = true
            weekCalendar.frame = weekCalendarContainer.bounds
            weekCalendar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            weekCalendarContainer.addSubview(weekCalendar)
            
            // Debug colors
            weekCalendar.backgroundColor = .systemYellow
            weekCalendarContainer.backgroundColor = .systemPurple
            
            print("🔵 Calendar frame after setup: \(weekCalendar.frame)")
            print("🔵 Container bounds: \(weekCalendarContainer.bounds)")
            
            weekCalendar.onDateSelected = { [weak self] date in
                print("📅 Date selected: \(date)")
                self?.currentSelectedDate = date
                self?.loadSymptomsForDate(date)
            }
        }
        
        private func loadSymptomsForDate(_ date: Date) {
            let dateKey = CalendarHelper.shared.dateKey(for: date)
            
            if let data = UserDefaults.standard.data(forKey: "symptoms_\(dateKey)"),
               let symptoms = try? JSONDecoder().decode([LoggedSymptoms].self, from: data) {
                selectedSymptoms = symptoms
            } else {
                selectedSymptoms = []
            }
            symptomsCollectionView.reloadData()
        }
        
        @objc func addTapped() {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        @IBAction func logButtonTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "showSymptomLogger", sender: self)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showSymptomLogger" {
                if let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
                    
                    symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
                    
                    symptomLoggerVC.onSymptomsSelected = { [weak self] (symptoms: [LoggedSymptoms]) in
                        guard let self = self else { return }
                        self.selectedSymptoms = symptoms
                        
                        let dateKey = CalendarHelper.shared.dateKey(for: self.currentSelectedDate)
                        if let encoded = try? JSONEncoder().encode(symptoms) {
                            UserDefaults.standard.set(encoded, forKey: "symptoms_\(dateKey)")
                        }
                        
                        self.symptomsCollectionView.reloadData()
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
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SymptomItemCollectionViewCell.identifier,
                for: indexPath
            ) as! SymptomItemCollectionViewCell
            
            let symptom = selectedSymptoms[indexPath.item]
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

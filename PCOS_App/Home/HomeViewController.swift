//
//  HomeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController, DataPassDelegate, HomeHeaderCollectionViewCellDelegate, LogPeriodCalendarDelegate, SleepCardCollectionViewCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedSymptoms: [SymptomItem] = []
        private var recommendationCards: [Recommendation] = recommendations
        private var currentSignalInfo: SignalInfo?

        // MARK: - Sleep state
        private var todaySleepLog: SleepLog? = nil
        private var sleepSkipped: Bool = false
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let bgColor = UIColor(hex: "#FCEEED")
            collectionView.backgroundColor = bgColor
            view.backgroundColor = bgColor
            
            let calendar = UIBarButtonItem(
                image: UIImage(systemName: "calendar"),
                style: .plain,
                target: self,
                action: #selector(leftBarButtonTapped)
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
            
            loadTodaysSymptoms()
            loadTodaySleepLog()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            showSleepLoggerIfNeeded()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            print("\nThis is HomeVC:", selectedSymptoms)
            loadTodaysSymptoms()
            loadTodaySleepLog()
            collectionView.reloadData()
        }
        
        private func loadTodaysSymptoms() {
            if let data = UserDefaults.standard.data(forKey: "todaysSymptoms"),
               let symptoms = try? JSONDecoder().decode([SymptomItem].self, from: data) {
                
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                
                let todaysSymptoms = symptoms.filter { symptom in
                    let symptomDate = calendar.startOfDay(for: symptom.date!)
                    return symptomDate == today
                }
                
                selectedSymptoms = todaysSymptoms
                
                if let firstSymptom = todaysSymptoms.first {
                    currentSignalInfo = getSignalInfo(for: firstSymptom.name) ?? defaultSignalInfo
                } else {
                    currentSignalInfo = nil
                }
                
                if let encoded = try? JSONEncoder().encode(todaysSymptoms) {
                    UserDefaults.standard.set(encoded, forKey: "todaysSymptoms")
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            }
        }
        
        private func loadTodaySleepLog() {
            todaySleepLog = SleepDatabase.shared.loadTodaySleepLog()
        }

        // MARK: - Sleep Logger Presentation
        private func showSleepLoggerIfNeeded() {
            // Only show once per calendar day
            let todayString = todayDateString()
            let lastShown = UserDefaults.standard.string(forKey: "sleepLoggerLastShownDate")
            guard lastShown != todayString else { return }
            // Don't show if already logged today
            guard todaySleepLog == nil else { return }

            // Mark as shown for today immediately so it won't pop twice
            UserDefaults.standard.set(todayString, forKey: "sleepLoggerLastShownDate")

            presentSleepLogger(isNotNowMode: false)
        }

        private func presentSleepLogger(isNotNowMode: Bool) {
            guard let loggerVC = storyboard?.instantiateViewController(withIdentifier: "SleepLoggerViewController") as? SleepLoggerViewController else {
                // Fallback: create programmatically if not in storyboard
                let loggerVC = SleepLoggerViewController()
                configureSleepLogger(loggerVC, isNotNowMode: isNotNowMode)
                present(loggerVC, animated: true)
                return
            }
            configureSleepLogger(loggerVC, isNotNowMode: isNotNowMode)
            present(loggerVC, animated: true)
        }

        private func configureSleepLogger(_ loggerVC: SleepLoggerViewController, isNotNowMode: Bool) {
            loggerVC.isNotNowMode = isNotNowMode

            // Sheet presentation – partial height with grabber, swipe-to-dismiss enabled
            loggerVC.modalPresentationStyle = .pageSheet
            if let sheet = loggerVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }

            loggerVC.onSleepSaved = { [weak self] in
                guard let self = self else { return }
                self.loadTodaySleepLog()
                self.sleepSkipped = false
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: 4))
                }
            }
            loggerVC.onDismissedWithoutSaving = { [weak self] in
                guard let self = self else { return }
                self.sleepSkipped = true
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: 4))
                }
            }
        }

        private func todayDateString() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: Date())
        }

        // MARK: - SleepCardCollectionViewCellDelegate
        func sleepCardDidTapLogSleep(_ cell: SleepCardCollectionViewCell) {
            presentSleepLogger(isNotNowMode: true)
        }

        func registerCells() {
            collectionView.register(UINib(nibName: "HomeHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "home_header")
            collectionView.register(UINib(nibName: "AddSymptomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddSymptomCollectionViewCell")
            collectionView.register(UINib(nibName: "SignalsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "signals_cell")
            collectionView.register(UINib(nibName: "QuickActionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "quick_actions_cell")
            collectionView.register(UINib(nibName: "CyclePatternCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cycle_pattern_cell")
            collectionView.register(UINib(nibName: "HomeRecommendationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "recommendation_cell")
            collectionView.register(UINib(nibName: "SleepCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "sleep_card_cell")
            collectionView.register(UINib(nibName: "HeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "header_cell")
        }
        
        @objc func leftBarButtonTapped() {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FullCalendarViewController") as? FullCalendarViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        @objc func addTapped() {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        // MARK: - Compositional Layout
        func createCompositionalLayout() -> UICollectionViewLayout {
            return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
                switch sectionIndex {
                case 0: return self.createHomeHeaderSection()
                case 1: return self.createSignalsSection()
                case 2: return self.createQuickActionsSection()
                case 3: return self.createRecommendationSection()
                case 4: return self.createSleepCardSection()
                case 5: return self.createCycleSection()
                default: return nil
                }
            }
        }
        
        func createHomeHeaderSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(380))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .zero
            return section
        }
        
        func createSignalsSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(105), heightDimension: .absolute(120))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(105), heightDimension: .absolute(120))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous
            
            addHeader(to: section)
            return section
        }
        
        func createQuickActionsSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(310))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
            addHeader(to: section)
            return section
        }
        
        func createRecommendationSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(285), heightDimension: .absolute(196))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(285), heightDimension: .absolute(196))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
            section.orthogonalScrollingBehavior = .continuous
            addHeader(to: section)
            return section
        }
        
        func createSleepCardSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
            addHeader(to: section)
            return section
        }
        
        func createCycleSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(547))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
            addHeader(to: section)
            return section
        }
        
        func addHeader(to section: NSCollectionLayoutSection) {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            section.boundarySupplementaryItems = [headerItem]
        }
        
        // MARK: - DataPassDelegate
        func passData(symptoms: [SymptomItem]) -> [SymptomItem] {
            self.selectedSymptoms = symptoms
            
            if let firstSymptom = symptoms.first {
                currentSignalInfo = getSignalInfo(for: firstSymptom.name) ?? defaultSignalInfo
            } else {
                currentSignalInfo = nil
            }
            
            let todaysKey = self.getTodaysKey()
            if let encoded = try? JSONEncoder().encode(symptoms) {
                UserDefaults.standard.set(encoded, forKey: todaysKey)
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
            return symptoms
        }
        
        // MARK: - HomeHeaderCollectionViewCellDelegate
        func homeHeaderCellDidTapLogPeriod(_ cell: HomeHeaderCollectionViewCell) {
            let calendarVC = LogPeriodCalendarViewController()
            calendarVC.delegate = self
            
            let navController = UINavigationController(rootViewController: calendarVC)
            navController.modalPresentationStyle = .pageSheet
            
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(navController, animated: true)
        }
        
        // MARK: - LogPeriodCalendarDelegate
        func didSavePeriodDates(_ dates: [Date], cycleDay: Int) {
            print("Received period dates: \(dates.count) dates")
            print("Current cycle day: \(cycleDay)")
            
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dates.forEach { date in
                print("Period date: \(formatter.string(from: date))")
            }
        }
        
        private func getTodaysKey() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "symptoms_\(formatter.string(from: Date()))"
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showSymptomLogger",
               let symptomLoggerVC = segue.destination as? SymptomLoggerViewController {
                
                symptomLoggerVC.delegate = self
                symptomLoggerVC.setSelectedSymptoms(selectedSymptoms)
                
                symptomLoggerVC.onSymptomsSelected = { [weak self] symptoms in
                    guard let self = self else { return }
                    
                    self.selectedSymptoms = symptoms
                    
                    if let firstSymptom = symptoms.first {
                        self.currentSignalInfo = getSignalInfo(for: firstSymptom.name) ?? defaultSignalInfo
                    } else {
                        self.currentSignalInfo = nil
                    }
                    
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
    }  

    // MARK: - UICollectionViewDataSource & Delegate
    extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 6
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            switch section {
            case 0: return 1
            case 1: return 1 + selectedSymptoms.count
            case 2: return 1
            case 3: return recommendationCards.count
            case 4: return 1
            case 5: return 1
            default: return 0
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_header", for: indexPath) as! HomeHeaderCollectionViewCell
                cell.delegate = self
                return cell
            }
            else if indexPath.section == 1 {
                if indexPath.item == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSymptomCollectionViewCell", for: indexPath) as! AddSymptomCollectionViewCell
                    return cell
                }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "signals_cell", for: indexPath) as! SignalsCollectionViewCell
                let symptomIndex = indexPath.item - 1
                if symptomIndex < selectedSymptoms.count {
                    let symptom = selectedSymptoms[symptomIndex]
                    if let signalInfo = getSignalInfo(for: symptom.name) {
                        cell.configure(with: signalInfo)
                    } else {
                        cell.configure(with: defaultSignalInfo)
                    }
                }
                return cell
            }
            else if indexPath.section == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "quick_actions_cell", for: indexPath) as! QuickActionsCollectionViewCell
                cell.configure()
                return cell
            }
            else if indexPath.section == 3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendation_cell", for: indexPath) as! HomeRecommendationCollectionViewCell
                let recommendation = recommendationCards[indexPath.item]
                cell.configure(with: recommendation)
                return cell
            }
            else if indexPath.section == 4 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sleep_card_cell", for: indexPath) as! SleepCardCollectionViewCell
                cell.delegate = self
                if let log = todaySleepLog {
                    cell.configure(with: log)
                } else if sleepSkipped {
                    cell.configureNotLogged()
                }
                // else: no configure call — default XIB appearance until first-open modal appears
                return cell
            }
            else if indexPath.section == 5 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cycle_pattern_cell", for: indexPath) as! CyclePatternCollectionViewCell
                return cell
            }
            return UICollectionViewCell()
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderCollectionReusableView
            
            if indexPath.section == 1 {
                headerView.configureHeader(with: "Today's PCOS Signals")
            } else if indexPath.section == 2 {
                headerView.configureHeader(with: "Quick Actions")
            } else if indexPath.section == 3 {
                headerView.configureHeader(with: "What May Happen Next")
            } else if indexPath.section == 4 {
                headerView.configureHeader(with: "Sleep Patterns")
            } else if indexPath.section == 5 {
                headerView.configureHeader(with: "Cycle Trends")
            } else {
                headerView.configureHeader(with: "Explore Routines")
            }
            return headerView
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if indexPath.section == 1 {
                if indexPath.item == 0 {
                    performSegue(withIdentifier: "showSymptomLogger", sender: self)
                } else {
                    let symptomIndex = indexPath.item - 1
                    if symptomIndex < selectedSymptoms.count {
                        print("Tapped on signal: \(selectedSymptoms[symptomIndex].name)")
                    }
                }
            }
            
            if indexPath.section == 3 {
                if indexPath.item == 0 {
                    performSegue(withIdentifier: "showProtein", sender: self)
                } else if indexPath.item == 1 {
                    performSegue(withIdentifier: "showInsulin", sender: self)
                } else if indexPath.item == 2 {
                    performSegue(withIdentifier: "showWorkoutPush", sender: self)
                }
            }
            
            if indexPath.section == 4 {
                // Always open the sleep report — tapping outside the button in the card goes here
                performSegue(withIdentifier: "showSleepReport", sender: nil)
            }

            
            if indexPath.section == 5 {
                performSegue(withIdentifier: "showCycleReport", sender: nil)
            }
        }
    }

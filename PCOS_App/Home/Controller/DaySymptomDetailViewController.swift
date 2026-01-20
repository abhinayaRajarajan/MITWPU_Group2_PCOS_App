//
//  DaySymptomDetailViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class DaySymptomDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var noSymptomsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daysSymptom: UITableView!
    @IBOutlet weak var CycleDayLabel: UILabel!
    
    
    var selectedDate: Date!
    private var symptoms: [SymptomItem] = []
    private let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadAndDisplay()
    }
    
    private func setupUI() {
        // Initially hide no symptoms label
        noSymptomsLabel.isHidden = true
        noSymptomsLabel.text = "No symptoms logged for this day"
        noSymptomsLabel.textColor = .systemGray
        noSymptomsLabel.font = .systemFont(ofSize: 16)
        noSymptomsLabel.textAlignment = .center
        
        // Setup cycle day label
        CycleDayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        CycleDayLabel.textAlignment = .center
        CycleDayLabel.textColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    }
    
    private func setupTableView() {
        //        daysSymptom.backgroundColor = UIColor(red: 252.0/255.0, green: 238.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        daysSymptom.delegate = self
        daysSymptom.dataSource = self
        daysSymptom.separatorStyle = .none
        daysSymptom.rowHeight = 60
        daysSymptom.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // Register custom cell
        daysSymptom.register(UITableViewCell.self, forCellReuseIdentifier: "SymptomCell")
    }
    
    private func loadAndDisplay() {
        updateDateLabel()
        loadSymptoms()
        updateCycleDay()
    }
    
    private func updateDateLabel() {
        guard let selectedDate = selectedDate else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        // formatter.dateFormat = "EEEE, MMMM d, yyyy"
        
        dateLabel.text = formatter.string(from: selectedDate)
        dateLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        dateLabel.textAlignment = .center
    }
    
    private func loadSymptoms() {
        guard let selectedDate = selectedDate else { return }
        
        symptoms = SymptomDataStore.loadSymptoms(for: selectedDate)
        
        if symptoms.isEmpty {
            daysSymptom.isHidden = true
            noSymptomsLabel.isHidden = false
        } else {
            daysSymptom.isHidden = false
            noSymptomsLabel.isHidden = true
        }
        
        daysSymptom.reloadData()
    }
    
    private func updateCycleDay() {
        guard let selectedDate = selectedDate else { return }
        
        let cycleDay = calculateCycleDay(for: selectedDate)
        
        if let day = cycleDay {
            CycleDayLabel.text = "Cycle Day \(day)"
        } else {
            CycleDayLabel.text = "Cycle day unknown"
        }
    }
    
    private func calculateCycleDay(for date: Date) -> Int? {
        // Load period dates from UserDefaults
        guard let timestamps = UserDefaults.standard.array(forKey: "SavedPeriodDates") as? [TimeInterval] else {
            return nil
        }
        
        let periodDates = timestamps.map { calendar.startOfDay(for: Date(timeIntervalSince1970: $0)) }
            .sorted()
        
        guard !periodDates.isEmpty else {
            return nil
        }
        
        let selectedDayStart = calendar.startOfDay(for: date)
        
        // Find the most recent period start date on or before the selected date
        var lastPeriodStart: Date?
        
        for periodDate in periodDates.reversed() {
            if periodDate <= selectedDayStart {
                lastPeriodStart = periodDate
                break
            }
        }
        
        guard let periodStart = lastPeriodStart else {
            return nil
        }
        
        // Calculate days since period start
        let components = calendar.dateComponents([.day], from: periodStart, to: selectedDayStart)
        
        if let days = components.day {
            return days + 1 // Cycle day 1 is the first day of period
        }
        
        return nil
    }
    
    // Public Method to Update Date
    func updateDate(_ newDate: Date) {
        
        selectedDate = newDate
        loadAndDisplay()
    }
    
    //UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell", for: indexPath)
        let symptom = symptoms[indexPath.row]
        
        // Clear previous content
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Configure cell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // Create card container
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cell.contentView.addSubview(cardView)
        
        // Icon background circle
        let iconBackgroundView = UIView()
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 0.1)
        iconBackgroundView.layer.cornerRadius = 22
        cardView.addSubview(iconBackgroundView)
        
        // Icon image
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        iconImageView.image = UIImage(named: symptom.icon)
        iconBackgroundView.addSubview(iconImageView)
        
        // Symptom name label
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .darkGray
        nameLabel.text = symptom.category
        cardView.addSubview(nameLabel)
        
        // Checkmark icon (since isSelected is true)
        //        let checkmarkImageView = UIImageView()
        //        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        //        checkmarkImageView.contentMode = .scaleAspectFit
        //        checkmarkImageView.tintColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        //        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        //        cardView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            // Card view constraints
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
            cardView.heightAnchor.constraint(equalToConstant: 64),
            
            // Icon background
            iconBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconBackgroundView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 44),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 44),
            
            // Icon image
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Name label
            nameLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            //            nameLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12)
            //,
            
            // Checkmark
            //            checkmarkImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            //            checkmarkImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            //            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            //            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return cell
    }
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

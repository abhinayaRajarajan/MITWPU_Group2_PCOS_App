//
//  DietLogsViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class DietCalendarLogsViewController: UIViewController {
    
    var dummyData = DataStore.sampleFoods
    var filteredData: [Food] = []
    var loggedDateKeys: Set<String> = []
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var loggedMeal: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Diet Logs"
        navigationItem.largeTitleDisplayMode = .never
        loggedMeal.delegate = self
        loggedMeal.dataSource = self // Tells the table view that this view controller will provide the data and handle user interactions
        
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = UIColor(hex: "fe7a96")
        
        if #available(iOS 16.0, *) {
            setupCalendarView()
        }
        
        // Use an @objc instance method for target-action
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        calculateLoggedDates()
        filterMealsByDate()
    }
    
    @available(iOS 16.0, *)
    func setupCalendarView() {
        // Access the calendar view from date picker
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let calendarView = self.findCalendarView(in: self.datePicker) {
                calendarView.delegate = self
            }
        }
    }
    
    @available(iOS 16.0, *)
    func findCalendarView(in view: UIView?) -> UICalendarView? {
        guard let view = view else { return nil }
        
        if let calendarView = view as? UICalendarView {
            return calendarView
        }
        
        for subview in view.subviews {
            if let found = findCalendarView(in: subview) {
                return found
            }
        }
        
        return nil
    }
    
    private func dateKey(for date: Date, calendar: Calendar = .current) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
    
    func calculateLoggedDates() {
        let calendar = Calendar.current
        loggedDateKeys = Set(dummyData.map { food in
            dateKey(for: food.timeStamp, calendar: calendar)
        })
    }
    
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        calculateLoggedDates()
        filterMealsByDate()
    }
    
    private func filterMealsByDate() {
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        
        filteredData = dummyData.filter { food in
            calendar.isDate(food.timeStamp, inSameDayAs: selectedDate)
        }
        
        loggedMeal.reloadData()
    }
}

@available(iOS 16.0, *)
extension DietCalendarLogsViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // Build a date from components and compare using canonical string key
        var comps = DateComponents()
        comps.year = dateComponents.year
        comps.month = dateComponents.month
        comps.day = dateComponents.day
        let cal = Calendar.current
        if let date = cal.date(from: comps) {
            let key = dateKey(for: date, calendar: cal)
            if loggedDateKeys.contains(key) {
                // Logged dates: pink dot
                return .default(color: UIColor(hex: "fe7a96"), size: .large)
            } else {
                // Non-logged dates: subtle gray dot
                return .default(color: UIColor.systemGray3, size: .small)
            }
        }
        return nil
    }
}

extension DietCalendarLogsViewController: UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 1 }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = filteredData[indexPath.row]
        cell.textLabel?.text = item.name
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeString = formatter.string(from: item.timeStamp)
        cell.detailTextLabel?.text = "\(item.calories) kcal • \(timeString)"
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 50 }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filteredData.count==0 { return "No meals logged"}
        return "Meals logged"
    }
}


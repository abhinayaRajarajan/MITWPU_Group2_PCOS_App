//
//  LogPeriodCalendarViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 07/01/26.
//

import UIKit

// MARK: - Protocol for passing data back
protocol LogPeriodCalendarDelegate: AnyObject {
    func didSavePeriodDates(_ dates: [Date], cycleDay: Int)
}

class LogPeriodCalendarViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var selectedDates: Set<Date> = []
    private var displayedMonths: [Date] = []
    private let calendar = Calendar.current
    private var hasScrolledToCurrentMonth = false
    
    // Delegate for passing data back
    weak var delegate: LogPeriodCalendarDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupDisplayedMonths()
        setupCollectionView()
        setupUI()
        loadSavedDates()
    }
    
    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        // Add title
        title = "Log Period"
        
        // Add DONE button to navigation bar
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        doneButton.tintColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 1.0)
        navigationItem.rightBarButtonItem = doneButton
        
        // Add Cancel button for modal presentation
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        cancelButton.tintColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 1.0)
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    // MARK: - Setup
    private func setupDisplayedMonths() {
        let today = Date()
        // Show previous 2 months, current month, and next month
        for i in -2...1 {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                displayedMonths.append(month)
            }
        }
    }
    
    // Scroll to Current Month
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only scroll once when the view is first laid out
        if !hasScrolledToCurrentMonth && displayedMonths.count > 2 {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.scrollToItem(at: IndexPath(item: 0, section: 2), at: .top, animated: false)
                self?.hasScrolledToCurrentMonth = true
            }
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.register(CalendarMonthHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MonthHeader")
        
        view.addSubview(collectionView)
    }
    
    private func setupUI() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        guard !selectedDates.isEmpty else {
            // Show alert if no dates selected
            let alert = UIAlertController(title: "No Dates Selected", message: "Please select at least one period date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Calculate cycle day based on first period date in current month
        let cycleDay = calculateCycleDay()
        
        // Convert Set to sorted Array
        let sortedDates = selectedDates.sorted()
        
        // Save to UserDefaults
        savePeriodDates(sortedDates)
        
        // Pass data back to delegate
        delegate?.didSavePeriodDates(sortedDates, cycleDay: cycleDay)
        
        print("Selected dates: \(sortedDates)")
        print("Cycle Day: \(cycleDay)")
        
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    private func calculateCycleDay() -> Int {
        let today = calendar.startOfDay(for: Date())
        
        // Get current month's start
        guard let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return 1
        }
        
        // Filter dates in current month
        let currentMonthDates = selectedDates.filter { date in
            calendar.isDate(date, equalTo: currentMonthStart, toGranularity: .month)
        }
        
        // Find the earliest (first) date in current month
        guard let firstPeriodDate = currentMonthDates.min() else {
            return 1
        }
        
        // Calculate days between first period date and today
        let components = calendar.dateComponents([.day], from: firstPeriodDate, to: today)
        let daysDifference = components.day ?? 0
        
        // Cycle day is daysDifference + 1 (since first day is day 1, not day 0)
        return daysDifference + 1
    }
    
    private func savePeriodDates(_ dates: [Date]) {
        // Convert dates to timestamps for saving
        let timestamps = dates.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timestamps, forKey: "SavedPeriodDates")
        UserDefaults.standard.synchronize()
    }
    
    private func loadSavedDates() {
        if let timestamps = UserDefaults.standard.array(forKey: "SavedPeriodDates") as? [TimeInterval] {
            selectedDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
            collectionView.reloadData()
        }
    }
    
    //selects 5 days in the beginning
    private func selectDateRange(from startDate: Date, days: Int = 5) {
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                selectedDates.insert(calendar.startOfDay(for: date))
            }
        }
    }
    
    private func getDaysInMonth(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        // Get all dates to fill the calendar grid
        while days.count < 42 { // 6 weeks max
            if calendar.isDate(currentDate, equalTo: date, toGranularity: .month) {
                days.append(currentDate)
            } else if currentDate < monthInterval.start {
                days.append(nil) // Empty cell before month starts
            } else if currentDate >= monthInterval.end {
                days.append(nil) // Empty cell after month ends
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
            
            // Stop if we've gone past the month and filled at least one week after
            if currentDate >= monthInterval.end && days.count >= 35 {
                break
            }
        }
        
        return days
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        selectedDates.contains(calendar.startOfDay(for: date))
    }
}

// MARK: - UICollectionViewDataSource
extension LogPeriodCalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displayedMonths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthDate = displayedMonths[section]
        return getDaysInMonth(for: monthDate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! CalendarDayCell
        
        let monthDate = displayedMonths[indexPath.section]
        let days = getDaysInMonth(for: monthDate)
        
        if let date = days[indexPath.item] {
            cell.configure(with: date, isToday: isToday(date), isSelected: isSelected(date))
        } else {
            cell.configure(with: nil, isToday: false, isSelected: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let monthHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MonthHeader", for: indexPath) as! CalendarMonthHeader
        let monthDate = displayedMonths[indexPath.section]
        
        // Show weekdays for ALL months
        monthHeader.configure(with: monthDate, showWeekdays: true)
        
        return monthHeader
    }
}

// MARK: - UICollectionViewDelegate
extension LogPeriodCalendarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let monthDate = displayedMonths[indexPath.section]
        let days = getDaysInMonth(for: monthDate)
        
        guard let selectedDate = days[indexPath.item] else { return }
        
        let normalizedDate = calendar.startOfDay(for: selectedDate)
        
        if selectedDates.contains(normalizedDate) {
            // Deselect
            selectedDates.remove(normalizedDate)
        } else {
            // Select - if it's the first selection, auto-select 5 days
            if selectedDates.isEmpty {
                selectDateRange(from: normalizedDate, days: 5)
            } else {
                selectedDates.insert(normalizedDate)
            }
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LogPeriodCalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32) / 7 // 32 for padding (16 left + 16 right)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Same height for all sections since all show weekdays now
        return CGSize(width: collectionView.bounds.width, height: 90)
    }
}

// MARK: - CalendarDayCell
class CalendarDayCell: UICollectionViewCell {
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(selectionView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 44),
            selectionView.heightAnchor.constraint(equalToConstant: 44),
            
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: selectionView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionView.layer.cornerRadius = selectionView.bounds.width / 2
    }
    
    func configure(with date: Date?, isToday: Bool, isSelected: Bool) {
        guard let date = date else {
            dayLabel.text = ""
            selectionView.isHidden = true
            checkmarkImageView.isHidden = true
            return
        }
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        dayLabel.text = "\(day)"
        
        selectionView.isHidden = false
        removeDashedBorder()
        
        if isSelected {
            if isToday {
                // FIXED: Solid pink CIRCLE with white checkmark for today when selected
                selectionView.backgroundColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
                selectionView.layer.borderColor = UIColor.clear.cgColor
                selectionView.layer.borderWidth = 0
                selectionView.layer.cornerRadius = 22 // Ensure it's circular
                dayLabel.isHidden = true
                checkmarkImageView.isHidden = false
                checkmarkImageView.tintColor = .white
            } else {
                // Dashed pink circle border with pink checkmark for other selected days
                selectionView.backgroundColor = .clear
                selectionView.layer.borderColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
                selectionView.layer.borderWidth = 2
                selectionView.layer.cornerRadius = 22
                addDashedBorder()
                dayLabel.isHidden = true
                checkmarkImageView.isHidden = false
                checkmarkImageView.tintColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
            }
        } else {
            dayLabel.isHidden = false
            checkmarkImageView.isHidden = true
            
            if isToday {
                // Pink text for today when not selected
                selectionView.isHidden = true
                dayLabel.textColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
                dayLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            } else {
                // No circle for other days
                selectionView.isHidden = true
                dayLabel.textColor = .black
                dayLabel.font = .systemFont(ofSize: 16)
            }
        }
    }
    
    private func addDashedBorder() {
        selectionView.layer.sublayers?.removeAll(where: { $0.name == "DashedBorder" })
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedBorder"
        shapeLayer.strokeColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = UIBezierPath(ovalIn: selectionView.bounds).cgPath
        
        selectionView.layer.addSublayer(shapeLayer)
        selectionView.layer.borderWidth = 0
    }
    
    private func removeDashedBorder() {
        selectionView.layer.sublayers?.removeAll(where: { $0.name == "DashedBorder" })
    }
}

// MARK: - CalendarMonthHeader
class CalendarMonthHeader: UICollectionReusableView {
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(monthLabel)
        addSubview(weekdayStackView)
        
        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            weekdayStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            weekdayStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 15),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Setup weekday labels
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .gray
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    func configure(with date: Date, showWeekdays: Bool = false) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: date)
        
        // Show/hide weekday row
        weekdayStackView.isHidden = !showWeekdays
    }
}

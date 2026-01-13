//
//  WorkoutCalendarViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class FullCalendarViewController: UIViewController {
    
//    private var collectionView: UICollectionView!
//    private var periodDates: Set<Date> = []
//    private var symptomDates: Set<Date> = []
//    private var displayedMonths: [Date] = []
//    private let calendar = Calendar.current
//    private var hasScrolledToCurrentMonth = false
//    
//    // Keep reference to the modal
//    private weak var symptomDetailVC: DaySymptomDetailViewController?
//    
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        title = "Calendar"
//        
//        setupDisplayedMonths()
//        setupCollectionView()
//        setupUI()
//        loadPeriodDates()
//        loadSymptomDates()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadPeriodDates()
//        loadSymptomDates()
//        collectionView.reloadData()
//    }
//
//    private func setupDisplayedMonths() {
//        let today = Date()
//        for i in -6...6 {
//            if let month = calendar.date(byAdding: .month, value: i, to: today) {
//                displayedMonths.append(month)
//            }
//        }
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        if !hasScrolledToCurrentMonth && displayedMonths.count > 6 {
//            DispatchQueue.main.async { [weak self] in
//                self?.collectionView.scrollToItem(at: IndexPath(item: 0, section: 6), at: .top, animated: false)
//                self?.hasScrolledToCurrentMonth = true
//            }
//        }
//    }
//    
//    private func setupCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
//        
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .white
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.showsVerticalScrollIndicator = true
//        
//        collectionView.register(FullCalendarDayCell.self, forCellWithReuseIdentifier: "DayCell")
//        collectionView.register(FullCalendarMonthHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MonthHeader")
//        
//        view.addSubview(collectionView)
//    }
//    
//    private func setupUI() {
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//    
//    // Data Loading
//    private func loadPeriodDates() {
//        if let timestamps = UserDefaults.standard.array(forKey: "SavedPeriodDates") as? [TimeInterval] {
//            periodDates = Set(timestamps.map { calendar.startOfDay(for: Date(timeIntervalSince1970: $0)) })
//        }
//    }
//    
//    private func loadSymptomDates() {
//        symptomDates.removeAll()
//        
//        let today = Date()
//        for i in 0..<365 {
//            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
//                let symptoms = SymptomDataStore.loadSymptoms(for: date)
//                if !symptoms.isEmpty {
//                    symptomDates.insert(calendar.startOfDay(for: date))
//                }
//            }
//        }
//    }
//    
//    //Helper Methods
//    private func getDaysInMonth(for date: Date) -> [Date?] {
//        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
//              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
//            return []
//        }
//        
//        var days: [Date?] = []
//        var currentDate = monthFirstWeek.start
//        
//        while days.count < 42 {
//            if calendar.isDate(currentDate, equalTo: date, toGranularity: .month) {
//                days.append(currentDate)
//            } else if currentDate < monthInterval.start {
//                days.append(nil)
//            } else if currentDate >= monthInterval.end {
//                days.append(nil)
//            }
//            
//            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
//            currentDate = nextDate
//            
//            if currentDate >= monthInterval.end && days.count >= 35 {
//                break
//            }
//        }
//        
//        return days
//    }
//    
//    private func isToday(_ date: Date) -> Bool {
//        calendar.isDateInToday(date)
//    }
//    
//    private func isPeriodDate(_ date: Date) -> Bool {
//        periodDates.contains(calendar.startOfDay(for: date))
//    }
//    
//    private func hasSymptoms(_ date: Date) -> Bool {
//        symptomDates.contains(calendar.startOfDay(for: date))
//    }
//    
//    private func showSymptomDetail(for date: Date) {
//        // If modal is already presented, just update the date
//        if let existingVC = symptomDetailVC, existingVC.isBeingPresented || presentedViewController == existingVC {
//                existingVC.updateDate(date)
//        } else {
//            // Present new modal
//            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "ExerciseDayListViewController") as? ExerciseDayListViewController {
//                detailVC.selectedDate = date
//                detailVC.modalPresentationStyle = .pageSheet
//                
//                if let sheet = detailVC.sheetPresentationController {
//                    sheet.detents = [.medium(), .large()]
//                    sheet.prefersGrabberVisible = true
//                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//                    sheet.largestUndimmedDetentIdentifier = .medium
//                }
//                
//                // Store weak reference
//                symptomDetailVC = detailVC
//                
//                present(detailVC, animated: true)
//            }
//        }
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//extension FullCalendarViewController: UICollectionViewDataSource {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return displayedMonths.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let monthDate = displayedMonths[section]
//        return getDaysInMonth(for: monthDate).count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! FullCalendarDayCell
//        
//        let monthDate = displayedMonths[indexPath.section]
//        let days = getDaysInMonth(for: monthDate)
//        
//        if let date = days[indexPath.item] {
//            cell.configure(
//                with: date,
//                isToday: isToday(date),
//                isPeriodDate: isPeriodDate(date),
//                hasSymptoms: hasSymptoms(date)
//            )
//        } else {
//            cell.configure(with: nil, isToday: false, isPeriodDate: false, hasSymptoms: false)
//        }
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        let monthHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MonthHeader", for: indexPath) as! FullCalendarMonthHeader
//        let monthDate = displayedMonths[indexPath.section]
//        
//        monthHeader.configure(with: monthDate, showWeekdays: true)
//        
//        return monthHeader
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension FullCalendarViewController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let monthDate = displayedMonths[indexPath.section]
//        let days = getDaysInMonth(for: monthDate)
//        
//        guard let selectedDate = days[indexPath.item] else { return }
//        
//        showSymptomDetail(for: selectedDate)
//    }
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//extension FullCalendarViewController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (collectionView.bounds.width - 32) / 7
//        return CGSize(width: width, height: width)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 90)
//    }
//}
//
//// MARK: - FullCalendarDayCell
//class FullCalendarDayCell: UICollectionViewCell {
//    
//    private let dayLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 16)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let backgroundCircle: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let symptomDot: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .systemGray3
//        view.layer.cornerRadius = 3
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        contentView.addSubview(backgroundCircle)
//        contentView.addSubview(dayLabel)
//        contentView.addSubview(symptomDot)
//        
//        NSLayoutConstraint.activate([
//            backgroundCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            backgroundCircle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            backgroundCircle.widthAnchor.constraint(equalToConstant: 44),
//            backgroundCircle.heightAnchor.constraint(equalToConstant: 44),
//            
//            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            symptomDot.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            symptomDot.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
//            symptomDot.widthAnchor.constraint(equalToConstant: 6),
//            symptomDot.heightAnchor.constraint(equalToConstant: 6)
//        ])
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        backgroundCircle.layer.cornerRadius = 22 // Half of 44
//    }
//    
//    func configure(with date: Date?, isToday: Bool, isPeriodDate: Bool, hasSymptoms: Bool) {
//        guard let date = date else {
//            dayLabel.text = ""
//            backgroundCircle.isHidden = true
//            symptomDot.isHidden = true
//            return
//        }
//        
//        let calendar = Calendar.current
//        let day = calendar.component(.day, from: date)
//        dayLabel.text = "\(day)"
//        
//        // Reset border
//        backgroundCircle.layer.borderWidth = 0
//        backgroundCircle.layer.borderColor = nil
//        
//        if isPeriodDate {
//            // Period date: Pink filled circle with white text
//            backgroundCircle.isHidden = false
//            backgroundCircle.backgroundColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
//            dayLabel.textColor = .white
//            dayLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        } else if isToday {
//            // Today (non-period): Pink outline circle
//            backgroundCircle.isHidden = false
//            backgroundCircle.backgroundColor = .clear
//            backgroundCircle.layer.borderWidth = 2
//            backgroundCircle.layer.borderColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
//            dayLabel.textColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
//            dayLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        } else {
//            // Regular day
//            backgroundCircle.isHidden = true
//            dayLabel.textColor = .black
//            dayLabel.font = .systemFont(ofSize: 16)
//        }
//        
//        // Show symptom dot if symptoms are logged
//        symptomDot.isHidden = !hasSymptoms
//    }
//}
//
//// MARK: - FullCalendarMonthHeader
//class FullCalendarMonthHeader: UICollectionReusableView {
//    
//    private let monthLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 20, weight: .semibold)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let weekdayStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.distribution = .fillEqually
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        addSubview(monthLabel)
//        addSubview(weekdayStackView)
//        
//        NSLayoutConstraint.activate([
//            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//            
//            weekdayStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            weekdayStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 15),
//            weekdayStackView.heightAnchor.constraint(equalToConstant: 30)
//        ])
//        
//        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
//        for weekday in weekdays {
//            let label = UILabel()
//            label.text = weekday
//            label.textAlignment = .center
//            label.font = .systemFont(ofSize: 14, weight: .medium)
//            label.textColor = .gray
//            weekdayStackView.addArrangedSubview(label)
//        }
//    }
//    
//    func configure(with date: Date, showWeekdays: Bool = false) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM yyyy"
//        monthLabel.text = formatter.string(from: date)
//        
//        weekdayStackView.isHidden = !showWeekdays
//    }
}

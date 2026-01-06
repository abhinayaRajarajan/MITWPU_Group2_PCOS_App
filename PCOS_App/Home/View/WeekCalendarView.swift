//
//  WeekCalendarView.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class WeekCalendarView: UIView {
    
    var dateCollectionView: UICollectionView!
    private var weekDays: [CalendarDay] = []
    private var hasScrolledToToday = false
    var selectedDate: Date = Date()
    
    var onDateSelected: ((Date) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("🟢 WeekCalendarView init(frame:) - \(frame)")
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("🟢 WeekCalendarView init(coder:)")
        setupView()
    }
    
    private func setupView() {
        print("🟢 Setting up WeekCalendarView...")
        backgroundColor = .systemBlue
        
        weekDays = CalendarHelper.shared.generateWeekDays()
        print("🟢 Generated \(weekDays.count) week days")
        
        setupDateCollectionView()
        
        print("🟢 Setup complete. Collection view: \(dateCollectionView != nil)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("🟢 WeekCalendarView layoutSubviews - frame: \(frame)")
        
        // Update collection view frame manually
        dateCollectionView.frame = bounds
        print("🟢 Collection view frame updated to: \(dateCollectionView.frame)")
        
        // Only scroll to today if we have a valid frame
        if frame.size.width > 0 && frame.size.height > 0 {
            scrollToTodayIfNeeded()
        }
    }
    
    private func scrollToTodayIfNeeded() {
        guard !hasScrolledToToday && weekDays.count > 0 else { return }
        
        print("🟢 Scrolling to today...")
        
        if let todayIndex = weekDays.firstIndex(where: { CalendarHelper.shared.isToday($0.date) }) {
            print("🟢 Today's index: \(todayIndex)")
            let indexPath = IndexPath(item: todayIndex, section: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                
                self.dateCollectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: .centeredHorizontally
                )
                
                self.hasScrolledToToday = true
                self.onDateSelected?(self.weekDays[todayIndex].date)
                
                print("✅ Scrolled to today successfully")
            }
        }
    }
    
    private func setupDateCollectionView() {
        print("🟢 Setting up date collection view...")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        layout.itemSize = CGSize(width: 70, height: 90)
        
        dateCollectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        dateCollectionView.backgroundColor = .systemPink
        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Manual resizing
        
        // Register cell
        if Bundle.main.path(forResource: "DateCollectionViewCell", ofType: "nib") != nil {
            print("✅ Found DateCollectionViewCell.xib")
            dateCollectionView.register(
                UINib(nibName: "DateCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "date_cell"
            )
        } else {
            print("❌ DateCollectionViewCell.xib NOT FOUND!")
            dateCollectionView.register(
                DateCollectionViewCell.self,
                forCellWithReuseIdentifier: "date_cell"
            )
        }
        
        dateCollectionView.showsHorizontalScrollIndicator = false
        dateCollectionView.allowsSelection = true
        
        addSubview(dateCollectionView)
        
        print("🟢 Date collection view added with frame: \(dateCollectionView.frame)")
    }
    
    func refreshCalendar() {
        weekDays = CalendarHelper.shared.generateWeekDays()
        dateCollectionView.reloadData()
        hasScrolledToToday = false
        setNeedsLayout()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension WeekCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("🟢 numberOfItemsInSection: \(weekDays.count)")
        return weekDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("🟢 cellForItemAt: \(indexPath.row)")
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "date_cell",
            for: indexPath
        ) as! DateCollectionViewCell
        
        let day = weekDays[indexPath.row]
        cell.configureCell(date: day)
        cell.isToday = CalendarHelper.shared.isToday(day.date)
        
        // Debug color
        cell.backgroundColor = .systemGreen
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        let selectedDay = weekDays[indexPath.row]
        selectedDate = selectedDay.date
        
        onDateSelected?(selectedDay.date)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

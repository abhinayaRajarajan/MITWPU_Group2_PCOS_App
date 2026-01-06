//
//  CalendarHelper.swift
//  PCOS_App
//
//  Created by SDC-USER on 06/01/26.
//

import Foundation

class CalendarHelper {
    
    static let shared = CalendarHelper()
    private let calendar = Calendar.current
    
    private init() {}

    // Generate date key for storage
    func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Check if a date is today
    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    // Generate week days (7 days for current week)
    func generateWeekDays() -> [CalendarDay] {
        let today = Date()
        var days: [CalendarDay] = []
        
        // Get the start of the week
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today) else {
            return []
        }
        
        var currentDate = weekInterval.start
        
        // Generate 7 days
        for _ in 0..<7 {
            let dayName = getDayName(from: currentDate)
            let dayNumber = String(calendar.component(.day, from: currentDate))
            let isToday = calendar.isDateInToday(currentDate)
            
            let calendarDay = CalendarDay(
                day: dayName,
                number: dayNumber,
                date: currentDate,
                isToday: isToday
            )
            
            days.append(calendarDay)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    // Get short day name (S, M, T, W, T, F, S)
    private func getDayName(from date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
        return dayNames[weekday - 1]
    }
}

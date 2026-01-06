import Foundation

class CalendarHelper {
    
    static let shared = CalendarHelper()
    private let calendar = Calendar.current
    
    private init() {}
    
    // Check if a date is today
    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    // Generate date key for storage
    func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // UPDATED: Generate all days for current month
    func generateMonthDays(for date: Date = Date()) -> [CalendarDay] {
        var days: [CalendarDay] = []
        
        // Get the range of days in the month
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        // Generate all days in the month
        for day in range {
            if let currentDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
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
            }
        }
        
        return days
    }
    
    // KEEP: Generate week days (7 days for current week)
    func generateWeekDays() -> [CalendarDay] {
        let today = Date()
        var days: [CalendarDay] = []
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today) else {
            return []
        }
        
        var currentDate = weekInterval.start
        
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
    
    // Get month name
    func getMonthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Move to next month
    func nextMonth(from date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date) ?? date
    }
    
    // Move to previous month
    func previousMonth(from date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }
}

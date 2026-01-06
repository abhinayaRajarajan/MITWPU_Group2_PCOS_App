//
//  CalendarDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import Foundation

//class CalendarHelper {
//    static let shared = CalendarHelper()
//    
//    private init() {}
//    
//    func generateWeekDays() -> [CalendarDay] {
//        var days: [CalendarDay] = []
//        let calendar = Calendar.current
//        let today = Date()
//
//        let startOfWeek = calendar.date(
//            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
//        )!
//
//        for i in 0..<7 {
//            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
//
//            let dayFormatter = DateFormatter()
//            dayFormatter.dateFormat = "EEEEE" // M T W
//            let day = dayFormatter.string(from: date)
//
//            let numberFormatter = DateFormatter()
//            numberFormatter.dateFormat = "d"
//            let number = numberFormatter.string(from: date)
//
//            days.append(CalendarDay(day: day, number: number, date: date))
//        }
//
//        return days
//    }
//
//    
//    func dateKey(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter.string(from: date)
//    }
//    
//    func isToday(_ date: Date) -> Bool {
//        return Calendar.current.isDate(date, inSameDayAs: Date())
//    }
//}

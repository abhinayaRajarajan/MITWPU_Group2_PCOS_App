//
//  CalendarModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/01/26.
//

import Foundation

struct CalendarDay {
    let day: String        // "S", "M", "T", etc.
    let number: String     // "06", "07", "08", etc.
    let date: Date         // The actual date
    let isToday: Bool      // Is this today?
}

//
//  Reminder.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var isEnabled: Bool
    var date: Date
    var checkIron: Bool
    var checkWater: Bool
    var checkPackingList: Bool
    
    init(id: UUID = UUID(), isEnabled: Bool = false, date: Date = Date(), checkIron: Bool = true, checkWater: Bool = true, checkPackingList: Bool = true) {
        self.id = id
        self.isEnabled = isEnabled
        self.date = date
        self.checkIron = checkIron
        self.checkWater = checkWater
        self.checkPackingList = checkPackingList
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}


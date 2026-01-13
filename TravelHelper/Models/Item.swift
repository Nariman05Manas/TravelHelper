//
//  Item.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import Foundation

struct Item: Identifiable, Codable {
    let id: UUID
    var name: String
    var isPacked: Bool
    var category: ItemCategory
    
    init(id: UUID = UUID(), name: String, isPacked: Bool = false, category: ItemCategory = .other) {
        self.id = id
        self.name = name
        self.isPacked = isPacked
        self.category = category
    }
}

enum ItemCategory: String, Codable, CaseIterable {
    case clothing = "Одежда"
    case documents = "Документы"
    case electronics = "Электроника"
    case toiletries = "Туалетные принадлежности"
    case medicine = "Медикаменты"
    case other = "Прочее"
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .documents: return "doc.text.fill"
        case .electronics: return "iphone"
        case .toiletries: return "sparkles"
        case .medicine: return "cross.case.fill"
        case .other: return "bag.fill"
        }
    }
}


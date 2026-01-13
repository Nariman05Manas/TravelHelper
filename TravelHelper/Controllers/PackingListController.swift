//
//  PackingListController.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import Foundation
import SwiftUI

class PackingListController: ObservableObject {
    @Published var items: [Item] = []
    
    private let itemsKey = "SavedPackingItems"
    
    init() {
        loadItems()
        if items.isEmpty {
            loadDefaultItems()
        }
    }
    
    func addItem(name: String, category: ItemCategory) {
        let newItem = Item(name: name, category: category)
        items.append(newItem)
        saveItems()
    }
    
    func togglePacked(item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isPacked.toggle()
            saveItems()
        }
    }
    
    func deleteItem(item: Item) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveItems()
    }
    
    private func loadDefaultItems() {
        items = [
            Item(name: "Паспорт", category: .documents),
            Item(name: "Билеты", category: .documents),
            Item(name: "Водительские права", category: .documents),
            Item(name: "Телефон", category: .electronics),
            Item(name: "Зарядное устройство", category: .electronics),
            Item(name: "Ноутбук", category: .electronics),
            Item(name: "Футболки", category: .clothing),
            Item(name: "Брюки", category: .clothing),
            Item(name: "Обувь", category: .clothing),
            Item(name: "Зубная щетка", category: .toiletries),
            Item(name: "Шампунь", category: .toiletries),
            Item(name: "Аптечка", category: .medicine)
        ]
        saveItems()
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            items = decoded
        }
    }
}


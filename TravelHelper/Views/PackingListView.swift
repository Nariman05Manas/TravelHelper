//
//  PackingListView.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import SwiftUI

struct PackingListView: View {
    @StateObject private var controller = PackingListController()
    @State private var showingAddItem = false
    @State private var selectedFilter: ItemCategory? = nil
    
    var filteredItems: [Item] {
        if let category = selectedFilter {
            return controller.items.filter { $0.category == category }
        }
        return controller.items
    }
    
    var groupedItems: [ItemCategory: [Item]] {
        Dictionary(grouping: filteredItems) { $0.category }
    }
    
    var packedCount: Int {
        filteredItems.filter { $0.isPacked }.count
    }
    
    var progressPercentage: Double {
        guard !filteredItems.isEmpty else { return 0 }
        return Double(packedCount) / Double(filteredItems.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фоновый градиент
                LinearGradient(
                    colors: [Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)), Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.15)
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Прогресс бар
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "suitcase.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("Собрано \(packedCount) из \(filteredItems.count)")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange, Color.yellow],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progressPercentage, height: 12)
                                    .animation(.spring(), value: progressPercentage)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding()
                    
                    // Фильтр по категориям
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChipNew(
                                icon: "square.grid.2x2.fill",
                                title: "Все",
                                isSelected: selectedFilter == nil,
                                action: { selectedFilter = nil }
                            )
                            
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                FilterChipNew(
                                    icon: category.icon,
                                    title: category.rawValue,
                                    isSelected: selectedFilter == category,
                                    action: { selectedFilter = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    // Список вещей
                    if filteredItems.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "suitcase.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.orange.opacity(0.6))
                            Text("Список пуст")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text("Добавьте вещи для поездки")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(Array(groupedItems.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { category in
                                Section(header: CategoryHeaderNew(category: category)) {
                                    ForEach(groupedItems[category] ?? []) { item in
                                        ItemRowNew(item: item, controller: controller)
                                    }
                                    .onDelete { indexSet in
                                        if let items = groupedItems[category] {
                                            let itemsToDelete = indexSet.map { items[$0] }
                                            for item in itemsToDelete {
                                                controller.deleteItem(item: item)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("🧳 Мой чемодан")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddItem = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(controller: controller)
            }
        }
    }
}

struct ItemRowNew: View {
    let item: Item
    let controller: PackingListController
    
    var body: some View {
        HStack(spacing: 14) {
            Button(action: {
                controller.togglePacked(item: item)
            }) {
                ZStack {
                    Circle()
                        .fill(item.isPacked ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    if item.isPacked {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(item.isPacked)
                    .foregroundColor(item.isPacked ? .secondary : .primary)
            }
            
            Spacer()
            
            Image(systemName: item.category.icon)
                .foregroundColor(item.isPacked ? .green : .orange)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
}

struct CategoryHeaderNew: View {
    let category: ItemCategory
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.subheadline)
                .foregroundColor(.orange)
            Text(category.rawValue)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct FilterChipNew: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color.orange, Color.yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color(.systemGray5)
                    }
                }
            )
            .cornerRadius(20)
            .shadow(color: isSelected ? Color.orange.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 2)
        }
    }
}

struct AddItemView: View {
    @ObservedObject var controller: PackingListController
    @Environment(\.dismiss) var dismiss
    @State private var itemName = ""
    @State private var selectedCategory: ItemCategory = .other
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Название вещи")) {
                        TextField("Введите название", text: $itemName)
                            .font(.body)
                    }
                    
                    Section(header: Text("Категория")) {
                        Picker("Категория", selection: $selectedCategory) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(.orange)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Добавить вещь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        if !itemName.isEmpty {
                            controller.addItem(name: itemName, category: selectedCategory)
                            dismiss()
                        }
                    }
                    .disabled(itemName.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(itemName.isEmpty ? .gray : .orange)
                }
            }
        }
    }
}

#Preview {
    PackingListView()
}

//
//  ReminderView.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import SwiftUI

struct ReminderView: View {
    @StateObject private var reminderController = ReminderController()
    @StateObject private var packingController = PackingListController()
    @State private var selectedDate = Date()
    
    var unpackedItemsCount: Int {
        packingController.items.filter { !$0.isPacked }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фоновый градиент
                LinearGradient(
                    colors: [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)).opacity(0.15), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)).opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Статус будильника
                        ZStack {
                            if reminderController.reminder.isEnabled {
                                LinearGradient(
                                    colors: [Color.green, Color.teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                            
                            VStack(spacing: 20) {
                                Image(systemName: reminderController.reminder.isEnabled ? "airplane.departure" : "airplane")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                                
                                if reminderController.reminder.isEnabled {
                                    VStack(spacing: 8) {
                                        Text("Готовы к вылету!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text(reminderController.reminder.formattedDate)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white.opacity(0.95))
                                        
                                        Text("Время выхода из дома")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                } else {
                                    Text("Будильник не установлен")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(30)
                        }
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Настройка времени
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.purple)
                                Text("Настройка времени")
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                            
                            DatePicker("Время вылета", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                        }
                        
                        // Чек-лист проверок
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "list.clipboard.fill")
                                    .foregroundColor(.purple)
                                Text("Перед выходом")
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                CheckboxRowNew(
                                    title: "Выключить утюг",
                                    icon: "flame.fill",
                                    color: .red,
                                    isChecked: reminderController.reminder.checkIron,
                                    action: {
                                        var updated = reminderController.reminder
                                        updated.checkIron.toggle()
                                        reminderController.updateReminder(updated)
                                    }
                                )
                                
                                CheckboxRowNew(
                                    title: "Закрыть воду",
                                    icon: "drop.fill",
                                    color: .blue,
                                    isChecked: reminderController.reminder.checkWater,
                                    action: {
                                        var updated = reminderController.reminder
                                        updated.checkWater.toggle()
                                        reminderController.updateReminder(updated)
                                    }
                                )
                                
                                CheckboxRowNew(
                                    title: "Проверить чемодан",
                                    icon: "suitcase.fill",
                                    color: .orange,
                                    isChecked: reminderController.reminder.checkPackingList,
                                    action: {
                                        var updated = reminderController.reminder
                                        updated.checkPackingList.toggle()
                                        reminderController.updateReminder(updated)
                                    }
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Информация о неупакованных вещах
                        if unpackedItemsCount > 0 {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Внимание!")
                                            .font(.headline)
                                            .foregroundColor(.orange)
                                        Text("\(unpackedItemsCount) \(unpackedItemsCount == 1 ? "вещь" : unpackedItemsCount < 5 ? "вещи" : "вещей") не упаковано")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                
                                NavigationLink(destination: PackingListView()) {
                                    HStack {
                                        Image(systemName: "suitcase.fill")
                                        Text("Открыть чемодан")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.orange, Color.red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Кнопки управления
                        VStack(spacing: 16) {
                            if reminderController.reminder.isEnabled {
                                Button(action: {
                                    reminderController.cancelNotification()
                                }) {
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Отменить")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.red, Color.pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                            } else {
                                Button(action: {
                                    var updated = reminderController.reminder
                                    updated.isEnabled = true
                                    updated.date = selectedDate
                                    reminderController.updateReminder(updated)
                                }) {
                                    HStack {
                                        Image(systemName: "bell.fill")
                                        Text("Установить будильник")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: selectedDate <= Date() ? [Color.gray] : [Color.green, Color.teal],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: (selectedDate <= Date() ? Color.gray : Color.green).opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .disabled(selectedDate <= Date())
                            }
                            
                            if reminderController.reminder.isEnabled {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.purple)
                                    Text("Вы получите напоминания за 1 час, за 30 минут и в указанное время")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("⏰ Будильник")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                selectedDate = reminderController.reminder.date
            }
        }
    }
}

struct CheckboxRowNew: View {
    let title: String
    let icon: String
    let color: Color
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isChecked ? color : Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 28)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ReminderView()
}

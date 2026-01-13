//
//  ReminderController.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import Foundation
import SwiftUI
import UserNotifications

class ReminderController: ObservableObject {
    @Published var reminder: Reminder = Reminder()
    
    private let reminderKey = "SavedReminder"
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        loadReminder()
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Уведомления разрешены")
            } else {
                print("Уведомления не разрешены")
            }
        }
    }
    
    func updateReminder(_ newReminder: Reminder) {
        reminder = newReminder
        saveReminder()
        scheduleNotification()
    }
    
    func scheduleNotification() {
        // Удаляем предыдущие уведомления
        notificationCenter.removeAllPendingNotificationRequests()
        
        guard reminder.isEnabled else { return }
        
        guard reminder.date > Date() else {
            print("Дата напоминания должна быть в будущем")
            return
        }
        
        // Создаем список проверок
        var checkList: [String] = []
        if reminder.checkIron {
            checkList.append("• Выключить утюг")
        }
        if reminder.checkWater {
            checkList.append("• Закрыть воду")
        }
        if reminder.checkPackingList {
            checkList.append("• Проверить список вещей")
        }
        
        let checkListText = checkList.isEmpty ? "" : "\n\nНе забудьте:\n\(checkList.joined(separator: "\n"))"
        
        // Создаем содержимое уведомления
        let content = UNMutableNotificationContent()
        content.title = "⏰ Время выходить из дома!"
        content.body = "Пора отправляться в путь!\(checkListText)"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        // Создаем триггер на указанную дату
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Создаем запрос
        let request = UNNotificationRequest(
            identifier: "travelReminder",
            content: content,
            trigger: trigger
        )
        
        // Добавляем уведомление
        notificationCenter.add(request) { error in
            if let error = error {
                print("Ошибка при создании уведомления: \(error.localizedDescription)")
            } else {
                print("Уведомление запланировано на \(self.reminder.formattedDate)")
            }
        }
        
        // Также создаем дополнительные напоминания за 30 минут и за 1 час до выхода
        if reminder.date.timeIntervalSinceNow > 1800 { // Если больше 30 минут
            let content30 = UNMutableNotificationContent()
            content30.title = "⏰ Напоминание: через 30 минут"
            content30.body = "Через 30 минут пора выходить из дома!\(checkListText)"
            content30.sound = .default
            
            let date30 = reminder.date.addingTimeInterval(-1800)
            let dateComponents30 = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date30)
            let trigger30 = UNCalendarNotificationTrigger(dateMatching: dateComponents30, repeats: false)
            
            let request30 = UNNotificationRequest(
                identifier: "travelReminder30min",
                content: content30,
                trigger: trigger30
            )
            
            notificationCenter.add(request30)
        }
        
        if reminder.date.timeIntervalSinceNow > 3600 { // Если больше 1 часа
            let content1h = UNMutableNotificationContent()
            content1h.title = "⏰ Напоминание: через 1 час"
            content1h.body = "Через 1 час пора выходить из дома! Не забудьте проверить все необходимое."
            content1h.sound = .default
            
            let date1h = reminder.date.addingTimeInterval(-3600)
            let dateComponents1h = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date1h)
            let trigger1h = UNCalendarNotificationTrigger(dateMatching: dateComponents1h, repeats: false)
            
            let request1h = UNNotificationRequest(
                identifier: "travelReminder1h",
                content: content1h,
                trigger: trigger1h
            )
            
            notificationCenter.add(request1h)
        }
    }
    
    func cancelNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
        var updatedReminder = reminder
        updatedReminder.isEnabled = false
        reminder = updatedReminder
        saveReminder()
    }
    
    func getUnpackedItemsCount(packingController: PackingListController) -> Int {
        return packingController.items.filter { !$0.isPacked }.count
    }
    
    private func saveReminder() {
        if let encoded = try? JSONEncoder().encode(reminder) {
            UserDefaults.standard.set(encoded, forKey: reminderKey)
        }
    }
    
    private func loadReminder() {
        if let data = UserDefaults.standard.data(forKey: reminderKey),
           let decoded = try? JSONDecoder().decode(Reminder.self, from: data) {
            reminder = decoded
        }
    }
}


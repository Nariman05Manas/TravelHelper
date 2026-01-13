//
//  TravelHelperApp.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import SwiftUI

@main
struct TravelHelperApp: App {
    
    init() {
        // Настройка для разрешения сетевых запросов
        URLCache.shared.diskCapacity = 50_000_000 // 50 MB
        URLCache.shared.memoryCapacity = 10_000_000 // 10 MB
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

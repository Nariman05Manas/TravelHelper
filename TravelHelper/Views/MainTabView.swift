//
//  MainTabView.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import SwiftUI

struct MainTabView: View {
    init() {
        // Настройка внешнего вида TabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Настройка цветов иконок
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemOrange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemOrange]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            PackingListView()
                .tabItem {
                    Label("Чемодан", systemImage: "suitcase.fill")
                }
            
            CountriesView()
                .tabItem {
                    Label("Страны", systemImage: "globe.europe.africa.fill")
                }
            
            ReminderView()
                .tabItem {
                    Label("Будильник", systemImage: "bell.fill")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    MainTabView()
}

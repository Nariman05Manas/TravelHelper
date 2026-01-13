//
//  CountriesController.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import Foundation
import SwiftUI

@MainActor
final class CountriesController: ObservableObject {
    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let countriesKey = "SavedCountries"
    
    // 🔗 СЮДА ВСТАВЬ СВОЙ RAW-URL С ГИТХАБА
    private let githubURL = URL(string: "https://raw.githubusercontent.com/Nariman05Manas/countries_example.json/refs/heads/main/countries_example.json")!
    
    init() {
        loadCountries()
        // Автоматически загружаем страны из GitHub при запуске
        Task {
            await fetchCountries()
        }
    }
    
    func fetchCountries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(from: githubURL)
            
            if let httpResponse = urlResponse as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            let countriesResponse = try decoder.decode(CountriesDataResponse.self, from: data)
            self.countries = countriesResponse.countries
            saveCountries()
            print("✅ Загружено \(countriesResponse.countries.count) стран из GitHub")
        } catch {
            print("❌ Ошибка загрузки стран: \(error)")
            errorMessage = "Не удалось загрузить страны. Проверьте интернет или попробуйте ещё раз."
            
            // Если не удалось загрузить и список пуст, используем дефолтные
            if countries.isEmpty {
                loadDefaultCountries()
            }
        }
        
        isLoading = false
    }
    
    func addCountry(_ country: Country) {
        countries.append(country)
        saveCountries()
    }
    
    func deleteCountry(country: Country) {
        countries.removeAll { $0.id == country.id }
        saveCountries()
    }
    
    private func loadDefaultCountries() {
        countries = [
            Country(
                name: "Франция",
                capital: "Париж",
                currency: "Евро (EUR)",
                currencyCode: "EUR",
                language: "Французский",
                timeZone: "UTC+1 (CET)",
                visaRequired: false,
                visaOffice: nil,
                requiredDocuments: nil,
                attractions: ["Эйфелева башня", "Лувр", "Версаль", "Нотр-Дам де Пари"],
                usefulInfo: "Франция - одна из самых посещаемых стран мира. Французская кухня славится на весь мир. Не забудьте попробовать круассаны, багеты и вино.",
                flag: "🇫🇷"
            ),
            Country(
                name: "Италия",
                capital: "Рим",
                currency: "Евро (EUR)",
                currencyCode: "EUR",
                language: "Итальянский",
                timeZone: "UTC+1 (CET)",
                visaRequired: false,
                visaOffice: nil,
                requiredDocuments: nil,
                attractions: ["Колизей", "Пизанская башня", "Венеция", "Ватикан"],
                usefulInfo: "Италия - родина пиццы, пасты и лучшего кофе. Посетите Колизей, Пизанскую башню и Венецию. Итальянцы очень дружелюбны, но говорят громко и жестикулируют.",
                flag: "🇮🇹"
            )
        ]
        saveCountries()
    }
    
    func saveCountries() {
        if let encoded = try? JSONEncoder().encode(countries) {
            UserDefaults.standard.set(encoded, forKey: countriesKey)
        }
    }
    
    private func loadCountries() {
        if let data = UserDefaults.standard.data(forKey: countriesKey),
           let decoded = try? JSONDecoder().decode([Country].self, from: data) {
            countries = decoded
        }
    }
}

//
//  CountriesView.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import SwiftUI

struct CountriesView: View {
    @StateObject private var controller = CountriesController()
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return controller.countries
        } else {
            return controller.countries.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.capital.localizedCaseInsensitiveContains(searchText) ||
                $0.language.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фоновый градиент
                LinearGradient(
                    colors: [Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if controller.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Загружаем страны мира...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredCountries.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "airplane.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            Text("Страны не найдены")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            if !searchText.isEmpty {
                                Text("Попробуйте другой запрос")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredCountries) { country in
                                    NavigationLink(destination: CountryDetailView(country: country, controller: controller)) {
                                        CountryCard(country: country)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await controller.fetchCountries()
                        }
                    }
                }
            }
            .navigationTitle("🌍 Путешествия")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Поиск направлений")
        }
    }
}

struct CountryCard: View {
    let country: Country
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Картинка или градиент
            if let imageURL = country.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 180)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 180)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .overlay(
                    // Темный градиент снизу
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // Флаг и виза
                    VStack {
                        HStack {
                            Spacer()
                            if country.visaRequired {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.caption)
                                    Text("Виза")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange)
                                .cornerRadius(20)
                                .padding(12)
                            }
                        }
                        Spacer()
                        // Флаг и название внизу
                        HStack(alignment: .bottom) {
                            Text(country.flag)
                                .font(.system(size: 50))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(country.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.caption)
                                    Text(country.capital)
                                        .font(.subheadline)
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                        }
                        .padding(16)
                    }
                )
            } else {
                // Если нет картинки - градиент с флагом
                ZStack {
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 180)
                    
                    VStack {
                        Text(country.flag)
                            .font(.system(size: 60))
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(country.capital)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            
            // Информация внизу карточки
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Label(country.language, systemImage: "text.bubble.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label(country.currency, systemImage: "banknote.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if !country.attractions.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(country.attractions.count) достопримечательност\(country.attractions.count == 1 ? "ь" : country.attractions.count < 5 ? "и" : "ей")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    CountriesView()
}

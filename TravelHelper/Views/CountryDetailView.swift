//
//  CountryDetailView.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import SwiftUI

struct CountryDetailView: View {
    let country: Country
    @ObservedObject var controller: CountriesController
    
    init(country: Country, controller: CountriesController? = nil) {
        self.country = country
        if let controller = controller {
            self._controller = ObservedObject(wrappedValue: controller)
        } else {
            self._controller = ObservedObject(wrappedValue: CountriesController())
        }
    }
    
    var currentCountry: Country {
        controller.countries.first(where: { $0.id == country.id }) ?? country
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Картинка страны с заголовком
                ZStack(alignment: .bottom) {
                    if let imageURL = currentCountry.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(height: 300)
                                    .overlay(ProgressView().tint(.white))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(height: 300)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .overlay(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.8)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 300)
                    }
                    
                    // Заголовок поверх картинки
                    HStack(spacing: 16) {
                        Text(currentCountry.flag)
                            .font(.system(size: 70))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentCountry.name)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                Text(currentCountry.capital)
                                    .font(.title3)
                            }
                            .foregroundColor(.white.opacity(0.95))
                        }
                        Spacer()
                    }
                    .padding(24)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Быстрая информация
                    HStack(spacing: 12) {
                        InfoChip(icon: "globe.europe.africa.fill", text: currentCountry.language, color: .blue)
                        InfoChip(icon: "banknote.fill", text: currentCountry.currencyCode, color: .green)
                        InfoChip(icon: "clock.fill", text: currentCountry.timeZone.prefix(6).description, color: .orange)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Виза
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    LinearGradient(
                                        colors: currentCountry.visaRequired ? [Color.orange, Color.red] : [Color.green, Color.teal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Визовый режим")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(currentCountry.visaRequired ? "Требуется виза" : "Безвизовый въезд")
                                    .font(.headline)
                                    .foregroundColor(currentCountry.visaRequired ? .orange : .green)
                            }
                            Spacer()
                        }
                        
                        if currentCountry.visaRequired {
                            if let visaOffice = currentCountry.visaOffice, !visaOffice.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Куда обращаться", systemImage: "building.2.fill")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text(visaOffice)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            if let documents = currentCountry.requiredDocuments, !documents.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label("Необходимые документы", systemImage: "list.clipboard.fill")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    ForEach(documents, id: \.self) { document in
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text(document)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Достопримечательности
                    if !currentCountry.attractions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.yellow, Color.orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(10)
                                
                                Text("Что посмотреть")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(currentCountry.attractions, id: \.self) { attraction in
                                    HStack(alignment: .center, spacing: 12) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.blue)
                                            .font(.title3)
                                            .frame(width: 30)
                                        
                                        Text(attraction)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Дополнительная информация
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(10)
                            
                            Text("Полезная информация")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InfoDetailRow(icon: "building.2.fill", title: "Столица", value: currentCountry.capital, color: .blue)
                            InfoDetailRow(icon: "dollarsign.circle.fill", title: "Валюта", value: currentCountry.currency, color: .green)
                            InfoDetailRow(icon: "text.bubble.fill", title: "Язык", value: currentCountry.language, color: .purple)
                            InfoDetailRow(icon: "clock.fill", title: "Часовой пояс", value: currentCountry.timeZone, color: .orange)
                        }
                        
                        Text(currentCountry.usefulInfo)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct InfoDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 35)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        CountryDetailView(country: Country(
            name: "Франция",
            capital: "Париж",
            currency: "Евро (EUR)",
            currencyCode: "EUR",
            language: "Французский",
            timeZone: "UTC+1 (CET)",
            visaRequired: false,
            visaOffice: nil,
            requiredDocuments: nil,
            attractions: ["Эйфелева башня", "Лувр", "Версаль", "Нотр-Дам"],
            usefulInfo: "Франция - одна из самых посещаемых стран мира. Обязательно посетите Эйфелеву башню, Лувр и Версаль.",
            flag: "🇫🇷"
        ))
    }
}

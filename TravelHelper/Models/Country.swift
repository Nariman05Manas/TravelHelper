//
//  Country.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import Foundation

struct Country: Identifiable, Codable {
    let id: UUID
    var name: String
    var capital: String
    var currency: String
    var currencyCode: String
    var language: String
    var timeZone: String
    var visaRequired: Bool
    var visaOffice: String? // Куда обращаться за визой
    var requiredDocuments: [String]? // Какие документы нужны для визы
    var attractions: [String] // Достопримечательности
    var usefulInfo: String
    var flag: String
    var imageURL: String? // URL картинки страны
    
    // Coding keys для декодирования
    enum CodingKeys: String, CodingKey {
        case id, name, capital, currency, currencyCode, language, timeZone
        case visaRequired, visaOffice, requiredDocuments, attractions, usefulInfo, flag, imageURL
    }
    
    // Custom декодирование - генерируем UUID если его нет в JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Генерируем UUID, если его нет в JSON
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        
        self.name = try container.decode(String.self, forKey: .name)
        self.capital = try container.decode(String.self, forKey: .capital)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.currencyCode = try container.decode(String.self, forKey: .currencyCode)
        self.language = try container.decode(String.self, forKey: .language)
        self.timeZone = try container.decode(String.self, forKey: .timeZone)
        self.visaRequired = try container.decode(Bool.self, forKey: .visaRequired)
        self.visaOffice = try? container.decode(String.self, forKey: .visaOffice)
        self.requiredDocuments = try? container.decode([String].self, forKey: .requiredDocuments)
        self.attractions = (try? container.decode([String].self, forKey: .attractions)) ?? []
        self.usefulInfo = try container.decode(String.self, forKey: .usefulInfo)
        self.flag = try container.decode(String.self, forKey: .flag)
        self.imageURL = try? container.decode(String.self, forKey: .imageURL)
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        capital: String,
        currency: String,
        currencyCode: String,
        language: String,
        timeZone: String,
        visaRequired: Bool,
        visaOffice: String? = nil,
        requiredDocuments: [String]? = nil,
        attractions: [String] = [],
        usefulInfo: String,
        flag: String,
        imageURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.capital = capital
        self.currency = currency
        self.currencyCode = currencyCode
        self.language = language
        self.timeZone = timeZone
        self.visaRequired = visaRequired
        self.visaOffice = visaOffice
        self.requiredDocuments = requiredDocuments
        self.attractions = attractions
        self.usefulInfo = usefulInfo
        self.flag = flag
        self.imageURL = imageURL
    }
}


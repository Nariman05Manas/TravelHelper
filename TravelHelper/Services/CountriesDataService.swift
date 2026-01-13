//
//  CountriesDataService.swift
//  TravelHelper
//
//  Created by qwerty on 13.01.2026.
//

import Foundation

struct CountriesDataResponse: Codable {
    let countries: [Country]
}

class CountriesDataService {
    static let shared = CountriesDataService()
    
    private let defaultGitHubURL = "https://raw.githubusercontent.com/Nariman05Manas/countries_example.json/refs/heads/main/countries_example.json"
    private let urlKey = "CountriesDataURL"
    
    private init() {}
    
    func getDataURL() -> String {
        return UserDefaults.standard.string(forKey: urlKey) ?? defaultGitHubURL
    }
    
    func setDataURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: urlKey)
    }
    
    func loadCountries(from urlString: String, completion: @escaping (Result<[Country], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        print("📡 CountriesDataService: Загрузка стран из \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Обработка ошибок сети
            if let error = error {
                print("❌ CountriesDataService: Ошибка сети - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Проверка HTTP ответа
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 CountriesDataService: HTTP статус - \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP ошибка: \(httpResponse.statusCode)"])
                    completion(.failure(error))
                    return
                }
            }
            
            // Проверка данных
            guard let data = data else {
                print("❌ CountriesDataService: Нет данных в ответе")
                let error = NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"])
                completion(.failure(error))
                return
            }
            
            // Парсинг JSON
            do {
                // Пробуем разные форматы JSON
                let decoder = JSONDecoder()
                
                // Формат 1: { "countries": [...] }
                if let response = try? decoder.decode(CountriesDataResponse.self, from: data) {
                    print("✅ CountriesDataService: Загружено \(response.countries.count) стран")
                    completion(.success(response.countries))
                    return
                }
                
                // Формат 2: прямой массив [...]
                if let countries = try? decoder.decode([Country].self, from: data) {
                    print("✅ CountriesDataService: Загружено \(countries.count) стран")
                    completion(.success(countries))
                    return
                }
                
                // Если не получилось, пробуем через JSONSerialization
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let countriesArray = json["countries"] as? [[String: Any]] {
                    var countries: [Country] = []
                    for countryDict in countriesArray {
                        if let country = self.parseCountry(from: countryDict) {
                            countries.append(country)
                        }
                    }
                    print("✅ CountriesDataService: Загружено \(countries.count) стран (через JSONSerialization)")
                    completion(.success(countries))
                    return
                }
                
                // Если это прямой массив
                if let countriesArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var countries: [Country] = []
                    for countryDict in countriesArray {
                        if let country = self.parseCountry(from: countryDict) {
                            countries.append(country)
                        }
                    }
                    print("✅ CountriesDataService: Загружено \(countries.count) стран (массив через JSONSerialization)")
                    completion(.success(countries))
                    return
                }
                
                throw NSError(domain: "ParseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось распарсить JSON"])
                
            } catch {
                print("❌ CountriesDataService: Ошибка парсинга - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func parseCountry(from dict: [String: Any]) -> Country? {
        guard let name = dict["name"] as? String,
              let capital = dict["capital"] as? String,
              let currency = dict["currency"] as? String,
              let currencyCode = dict["currencyCode"] as? String,
              let language = dict["language"] as? String,
              let timeZone = dict["timeZone"] as? String,
              let visaRequired = dict["visaRequired"] as? Bool,
              let usefulInfo = dict["usefulInfo"] as? String,
              let flag = dict["flag"] as? String else {
            return nil
        }
        
        // Опциональные поля
        let visaOffice = dict["visaOffice"] as? String
        let requiredDocuments = dict["requiredDocuments"] as? [String]
        let attractions = dict["attractions"] as? [String] ?? []
        let imageURL = dict["imageURL"] as? String
        
        return Country(
            name: name,
            capital: capital,
            currency: currency,
            currencyCode: currencyCode,
            language: language,
            timeZone: timeZone,
            visaRequired: visaRequired,
            visaOffice: visaOffice,
            requiredDocuments: requiredDocuments,
            attractions: attractions,
            usefulInfo: usefulInfo,
            flag: flag,
            imageURL: imageURL
        )
    }
}


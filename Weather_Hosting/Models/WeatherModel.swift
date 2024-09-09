//
//  WeatherModel.swift
//  Weather_SwiftUI
//
//  Created by Brian Novie on 9/4/24.
//

import Foundation

// https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}

struct Coordinates: Decodable {
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}

struct TemperatureRange: Decodable {
    let current: Double
    let max: Double
    let min: Double

    enum CodingKeys: String, CodingKey {
        case current = "temp"
        case max = "temp_max"
        case min = "temp_min"
    }
}

extension TemperatureRange {
    var formattedTemp: String {
        return String(format: "%.0fº", current)
    }
    var formattedTempRange: String {
        return "\(String(format: "H:%.0fº", max))  \(String(format: "L:%.0fº", min))"
    }
}

struct Weather: Decodable {
    let name: String
    let detailedName: String
    let id: Int
    let icon: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "main"
        case detailedName = "description"
        case icon
    }
}

extension Weather {
    var weatherIconUrl: URL? {
        // Different then documentation given
        URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
}



struct WeatherModel: Decodable {
    
    let weather: [Weather]
    let dailyTemperature: TemperatureRange
    let coordinates: Coordinates
    let locationName: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case dailyTemperature = "main"
        case weather
        case locationName = "name"
        case date = "dt"
        case coordinates = "coord"
    }
}

extension WeatherModel: Identifiable {
    var id: Date {
        return date
    }
}

struct WeatherTimeModel: Decodable {
    
    let weather: [Weather]
    let dailyTemperature: TemperatureRange
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case dailyTemperature = "main"
        case weather
        case date = "dt"
    }
}

extension WeatherTimeModel: Identifiable {
    var id: Date {
        return date
    }
}

extension WeatherTimeModel {
    var formattedTime: String {
        let dayFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        if Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date) {
            dayFormatter.dateStyle = .medium
            dayFormatter.timeStyle = .none
            dayFormatter.doesRelativeDateFormatting = true
        } else {
            dayFormatter.dateFormat = "EEE"
        }
        timeFormatter.dateFormat = " ha"
        
        let day = dayFormatter.string(from: date).capitalized
        let time = timeFormatter.string(from: date).uppercased()

        return day + time
    }
}


// api.openweathermap.org/data/2.5/forecast/daily?lat={lat}&lon={lon}&cnt={cnt}&appid={API key}

// api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
struct ForecastModel: Decodable {
    let weatherList: [WeatherTimeModel]
    
    enum CodingKeys: String, CodingKey {
        case weatherList = "list"
    }
}

struct Geocode: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?
}


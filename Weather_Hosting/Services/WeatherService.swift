//
//  WeatherService.swift
//  Weather_SwiftUI
//
//  Created by Brian Novie on 9/4/24.
//

import Foundation
// https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
//https://api.openweathermap.org/data/2.5/forecast


final class WeatherService {
    private let apiKey = "065c0840ca9ca216d6d795ed2c134977"
    private let base = "https://api.openweathermap.org/data/2.5/weather"
    private let forecast = "https://api.openweathermap.org/data/2.5/forecast"
    private let geocode = "http://api.openweathermap.org/geo/1.0/direct"
//    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
//        //try await apiService.fetchProduct(identifier: identifier)
//        let url = URL(string: base+"?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial")!
//        let (data, response) = try await URLSession.shared.data(from: url)
//        
//        print(response)
//
//        let decoder = JSONDecoder()
//        return try decoder.decode(WeatherModel.self, from: data)
//    }
 
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print(response)
            if httpResponse.statusCode != 200 {
                // This is where we could handle error or throw it
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        return try decoder.decode(T.self, from: data)
    }

    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastModel {
        let url = URL(string: forecast+"?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial")!
        
        return try await fetch(from: url)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        //try await apiService.fetchProduct(identifier: identifier)
        let url = URL(string: base+"?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial")!

        return try await fetch(from: url)
    }
    
    func fetchGeocode(locationName: String) async throws -> [Geocode] {
        //try await apiService.fetchProduct(identifier: identifier)
        let url = URL(string: geocode+"?q=\(locationName)&appid=\(apiKey)&units=imperial")!

        return try await fetch(from: url)
    }

}

/*
 public func fetchProduct(identifier: String) async throws -> Product {
     let response: ProductResponse = try await httpClient.execute(request: .product(identifier: identifier))
     return ProductDomain.Product.Mapper.from(response: response)
 }

 */

//https://maps-api.apple.com/v1/geocode?q=

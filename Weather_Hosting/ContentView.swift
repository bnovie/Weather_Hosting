//
//  ContentView.swift
//  Weather_SwiftUI
//
//  Created by Brian Novie on 9/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: WeatherViewModel = WeatherViewModel()
    @StateObject var forecastModel: ForecastViewModel = ForecastViewModel()
    @ObservedObject var locationDataManager: LocationDataManager

    let backgroundGradient = LinearGradient(
        colors: [Color.blue.opacity(0.4), Color.blue],
        startPoint: .top, endPoint: .bottom)

    var body: some View {
        VStack(spacing:0) {
            switch viewModel.state {
            case .initial:
                Text("Initial State")
            case .loading:
                Text("Loading")
            case .loaded(let model):
                VStack {
                    Text(model.locationName)
                        .font(.largeTitle)
                    Text(model.dailyTemperature.formattedTemp)
                        .font(.system(size: 80))
                    Text(model.weather.first?.detailedName.capitalized ?? "")
                        .font(.title2)
                        .padding(.bottom, 8)
                    Text(model.dailyTemperature.formattedTempRange)
                        .font(.title3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background {
                    backgroundGradient
                        .ignoresSafeArea()
                }
            case .error(let error):
                Text(error.localizedDescription)
            }
            switch forecastModel.state {
            case .initial:
                Text("Initial State 5 day forecast")
            case .loading:
                Text("Loading 5 day forecast")
            case .loaded(let forecast):
                List(forecast.weatherList) { forecastTime in
                    HStack {
                        Text(forecastTime.formattedTime)
                        Spacer()
                        asyncImage(forecastTime.weather.first?.weatherIconUrl, size: 64)
                        Text(forecastTime.dailyTemperature.formattedTemp)
                    }
                    .listRowBackground(backgroundGradient)
                }
                .listStyle(PlainListStyle())
            case .error(let error):
                Text("Fetching 5 day Forecast failed \(error.localizedDescription)")
            }
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .task {
            await viewModel.fetchWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
            await forecastModel.fetchForecast(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
        }
        .onChange(of: locationDataManager.latitude) {
            Task {
                await viewModel.fetchWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                await forecastModel.fetchForecast(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
            }
        }

    }
    
    private func asyncImage(_ url: URL?, size: CGFloat = 40) -> some View {
        AsyncImage(url: url) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            EmptyView()
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ContentView(locationDataManager: LocationDataManager())
}



final class WeatherViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case loaded(WeatherModel)
        case error(Error)
    }

    @Published private(set) var state: State = .initial
    private let service = WeatherService()

    @MainActor
    func fetchWeather(latitude: Double, longitude: Double) async {
        state = .loading
        do {
            let weather = try await service.fetchWeather(latitude: latitude, longitude: longitude)
            state = .loaded(weather)
        } catch {
            state = .error(error)
        }
    }
}

final class ForecastViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case loaded(ForecastModel)
        case error(Error)
    }
    @Published private(set) var state: State = .initial
    private let service = WeatherService()

    @MainActor
    func fetchForecast(latitude: Double, longitude: Double) async {
        state = .loading
        do {
            let forecast = try await service.fetchForecast(latitude: latitude, longitude: longitude)
            state = .loaded(forecast)
        } catch {
            state = .error(error)
        }
    }
}


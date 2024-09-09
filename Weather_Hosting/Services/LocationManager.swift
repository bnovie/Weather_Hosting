//
//  LocationManager.swift
//  Weather_SwiftUI
//
//  Created by Brian Novie on 9/7/24.
//

import Foundation
import CoreLocation

class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var latitude: Double = 43.0
    @Published var longitude: Double = -75.5
    // Users coordinates
    var userLatitude: Double = 0
    var userLongitude: Double = 0
    var searchTerm: String = ""

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        readCoordinates()
    }
    
    func request() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            // Insert code here of what should happen when Location services are authorized
            print("authorized")
            guard let location = locationManager.location else {
                return
            }
            userLatitude = latitude
            userLongitude = longitude
        case .restricted, .denied:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            print("error: denied")
        case .notDetermined:        // Authorization not determined yet.
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Insert code to handle location updates
        let locationArray = locations as NSArray
        guard let location = locationArray.lastObject as? CLLocation else { return }
        userLatitude = location.coordinate.latitude
        userLongitude = location.coordinate.longitude
        if searchTerm.isEmpty {
            latitude = userLatitude
            longitude = userLongitude
        }
        print("latitude \(latitude) longitude \(longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    // This needs throttling - typing fast and things could come out of order
    func fetchCoordinates( addressString : String) {
        guard addressString.count > 5 else {
            latitude = userLatitude
            longitude = userLongitude
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    self?.latitude = location.coordinate.latitude
                    self?.longitude = location.coordinate.longitude
                    self?.searchTerm = addressString
                    self?.persistCoordinates()

                    return
                }
            }
        }
    }

    // This should really be its own class
    func persistCoordinates() {
        let defaults = UserDefaults.standard
        defaults.set(latitude, forKey: "latitude")
        defaults.set(longitude, forKey: "longitude")
        defaults.set(searchTerm, forKey: "searchTerm")
    }
    
    func readCoordinates() {
        let defaults = UserDefaults.standard
        
        if let searchTerm = defaults.string(forKey: "searchTerm") {
            latitude = defaults.double(forKey: "latitude")
            longitude = defaults.double(forKey: "longitude")
            self.searchTerm = searchTerm
        } else {
            //default to NYC
            latitude = userLatitude
            longitude = userLongitude
            searchTerm = ""
        }
    }

}

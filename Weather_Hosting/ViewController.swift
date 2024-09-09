//
//  ViewController.swift
//  Weather_Hosting
//
//  Created by Brian Novie on 9/8/24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController, UISearchResultsUpdating {
        
    var locationDataManager = LocationDataManager()
    var contentView: UIHostingController<ContentView>!
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView = UIHostingController(rootView: ContentView(locationDataManager: locationDataManager))
        addChild(contentView)
        view.addSubview(contentView.view)
        setupConstraints()
        setupSearch()
    }
    
    private func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func setupSearch() {
        title = "Weather App"
        searchController.searchBar.placeholder = "Location"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        let defaults = UserDefaults.standard
        if let searchTerm = defaults.string(forKey: "searchTerm") {
            if searchTerm.hasSuffix(", US") {
                searchController.searchBar.text = searchTerm.replacingOccurrences(of: ", US", with: "")
            } else {
                searchController.searchBar.text = searchTerm
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text else { return }
        
        print(searchTerm)
        locationDataManager.fetchCoordinates(addressString: searchTerm + ", US") // Try to force it to look in US
    }

}


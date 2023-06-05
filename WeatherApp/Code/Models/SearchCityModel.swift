//
//  SearchCityModel.swift
//  WeatherApp
//
//  Created by Karun Kumaron 02/06/23.
//

import Foundation

// MARK: - SearchCityModel
struct SearchCityModel: Codable {
    let name: String?
    let localNames: [String: String]?
    let lat, lon: Double?
    let country, state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

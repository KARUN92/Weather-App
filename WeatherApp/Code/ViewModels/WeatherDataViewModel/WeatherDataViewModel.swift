//
//  WeatherDataViewModel.swift
//  WeatherApp
//
//  Created by Karun Kumaron 02/06/23.
//

import Foundation

struct WeatherDataViewModel {
    func getWeatherData(withCoordinates latitude: Double, longitude: Double, completionHandler: @escaping (WeatherDataModel?, String?) -> ()) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)1&lon=\(longitude)&appid=\(Constants.WeatherAPIKEY)")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "Some error has occured")")
                completionHandler(nil, error?.localizedDescription)
                return
            }
            
            guard let weatherData = data else {
                print("Data not available")
                completionHandler(nil, "Data not available")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(WeatherDataModel.self, from: weatherData)
                print(result)
                completionHandler(result, nil)
            } catch {
                print("Error while parsing the response")
                completionHandler(nil, "Error while parsing the response")
            }
        }.resume()
    }
}

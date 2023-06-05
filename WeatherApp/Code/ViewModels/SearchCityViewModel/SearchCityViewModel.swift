//
//  SearchCityViewModel.swift
//  WeatherApp
//
//  Created by Karun Kumaron 02/06/23.
//

import Foundation

struct SearchCityViewModel {
    func getCity(withSearchText strSearch: String, completionHandler: @escaping ([SearchCityModel]?, String?) -> ()) {
        let search = strSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(search)&limit=5&appid=\(Constants.WeatherAPIKEY)")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "Some error has occured")")
                completionHandler(nil, error?.localizedDescription)
                return
            }
            
            guard let searchData = data else {
                print("Data not available")
                completionHandler(nil, "Data not available")
                return
            }
            
            do {
                let result = try JSONDecoder().decode([SearchCityModel].self, from: searchData)
                print(result)
                completionHandler(result, nil)
            } catch {
                print("Error while parsing the response")
                completionHandler(nil, "Error while parsing the response")
            }
        }.resume()
    }
}

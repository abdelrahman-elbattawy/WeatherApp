//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Aboody on 19/07/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import CoreLocation

protocol APICallerDelegate {
    func didUpdateWeaher(weather: WeahterModel)
    func didFailWith(_ error: Error)
}

struct APICaller {
    
    var delegate: APICallerDelegate?
    
    func fetchWeatherBy(_ cityName: String) {
        guard let weaherURL = URL(string: "\(baseURL)q=\(cityName)&appid=\(API_KEY)&units=metric") else {
            return
        }
        
        performRequest(weaherURL)
    }
    
    func fetchWeatherBy(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        guard let weaherURL = URL(string: "\(baseURL)lat=\(latitude)&lon=\(longitude)&appid=\(API_KEY)&units=metric") else {
            return
        }
        
        performRequest(weaherURL)
    }
    
    private func performRequest(_ url: URL) {
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                
                if error != nil {
                    delegate?.didFailWith(error!)
                }
                
                return
            }
            
            guard let weather = self.jsonParse(data) else {
                return
            }
            
            delegate?.didUpdateWeaher(weather: weather)
        }
        
        task.resume()
    }
    
    private func jsonParse(_ weatherData: Data) -> WeahterModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let id = decodedData.weather[0].id
            
            let weahterModel = WeahterModel(conditionId: id, cityName: name, temperature: temp)
            
            return weahterModel
            
        } catch {
            delegate?.didFailWith(error)
            return nil
        }
    }
}

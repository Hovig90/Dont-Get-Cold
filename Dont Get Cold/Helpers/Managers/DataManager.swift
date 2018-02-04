//
//  DataManager.swift
//  Don't Get Cold
//
//  Created by Hovig Kousherian on 1/21/18.
//  Copyright © 2018 Hovig Kousherian. All rights reserved.
//

import Foundation

class DataManager {
    
    //MARK: Members
    enum Units: String {
        case metric
        case imperial
        case kelvin
    }
    
    //MARK: Public
    static func getCurrentWeatherData(withCityName city: String?, cityID id: String?, units: Units, completion: @escaping (Weather?, Error?) -> Void) {
        DataManager.getCurrentWeatherData(withParameter: "APPID=\(AppConstants.WeatherApiKey)&q=\(city ?? "")&id=\(id ?? "0")&units=\(units.rawValue)", completion: completion)
    }
    
    static func getForecastData(withCityName city: String?, cityID id: String?, units: Units, andCount cnt: Int, completion: @escaping (Forecast?, Error?) -> Void) {
        RequestManager.request(withURL: AppConstants.forecastDailyUrl, parameters: "APPID=\(AppConstants.WeatherApiKey)&q=\(city ?? "")&id=\(id ?? "0")&units=\(units.rawValue)&cnt=\(cnt)") { (data, responce, error) in
            guard error == nil, let data = data?.convertToDictionary() else {
                completion(nil, error)
                return
            }
            
            completion(Forecast(response: nil, representation: data), nil)
        }
    }
    
    static func getCities(completion: @escaping (([City]?) -> Void))  {
        DispatchQueue.global(qos: .background).async {
            let url = Bundle.main.url(forResource: "city.list", withExtension: ".json")
            if let url = url {
                do {
                    let data = try Data(contentsOf: url)
                    let dict = data.convertToArrayOfDictionaries()
                    var cities: [City] = []
                    for city in dict! {
                        cities.append(City(with: city)!)
                    }
                    completion(cities)
                } catch {
                    completion(nil)
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: Private
    private static func getCurrentWeatherData(withParameter param: String, completion: @escaping (Weather?, Error?) -> Void) {
        RequestManager.request(withURL: AppConstants.BaseUrl + AppConstants.Encoding.weather.rawValue, parameters: param) { (data, responce, error) in
            guard error == nil, let data = data?.convertToDictionary() else {
                completion(nil, error)
                return
            }
            
            completion(Weather(response: nil, representation: data), nil)
        }
    }
}
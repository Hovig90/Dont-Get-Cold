//
//  MainViewController.swift
//  Dont Get Cold
//
//  Created by Hovig Kousherian on 2/3/18.
//  Copyright © 2018 Hovig Kousherian. All rights reserved.
//

import UIKit
import CoreLocation

extension MainViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        CLGeocoder().geocodeAddressString("Aleppo,SY") { (pl, error) in
//            print(error)
//        }
        CLGeocoder().reverseGeocodeLocation(locations.first!) { (placemarks, error) in
            if let placemarks = placemarks, let placemark = placemarks.first, let locality = placemark.locality, let counrtyCode = placemark.isoCountryCode  {
                self.requestWeatherData(forCity: locality + "," + counrtyCode, isCurrent: true)
            }
        }
    }
}

extension MainViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let weatherViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherViewController") as? WeatherViewController {
            weatherViewController.weatherDataModel = selectedCities[indexPath.row]
            self.navigationController?.pushViewController(weatherViewController, animated: true)
        }
    }
}

extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        
        let weather = selectedCities[indexPath.row]
        cell.cityNameLabel.text = weather.cityName
        cell.subTitleLabel.text = weather.temperatureSummary
        cell.tempLabel.text = weather.temperature
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCities.count
    }
}

class MainViewController: BaseViewController {

    //MARK: Members
    var selectedCities: [CurrentWeather] =  []
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        /*DataManager.getCities { (cities) in
         if let cities = cities {
         self.citiess = cities
         
         let x = self.citiess.filter({ (city) -> Bool in
         if (city.coord?.lon)! == self.coordinates?.lon && (city.coord?.lat)! == self.coordinates?.lat {
         return true
         }
         return false
         })
         print(x)
         }
         }
         */
        
        tableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherTableViewCell")
        tableView.separatorStyle = .none
        
        PermissionManager.permission.requestPermission(permission: .Location, target: self) { (error) in
            
        }
        LocationManager.shared.configure(withDelegate: self)
        
    }
    
    //MARK: Private
    private func requestWeatherData(forCity city: String, isCurrent: Bool = false) {
        DataManager.getCurrentWeatherData(withCityName: city, cityID: nil, units: .metric) { (weather, error) in
            guard error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                isCurrent ? self.selectedCities.replace(at: 0, withElement: CurrentWeather(withWeather: weather!)) : self.selectedCities.append(CurrentWeather(withWeather: weather!))
                self.tableView.reloadData()
                
            }
        }
    }
}


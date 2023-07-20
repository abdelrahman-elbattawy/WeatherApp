//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searhTextField: UITextField!
    
    //MARK: - Properties
    private var apiCaller = APICaller()
    private let locationManager = CLLocationManager()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        searhTextField.delegate = self
        apiCaller.delegate = self
    }
    
    //MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searhTextField.endEditing(true)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}


//MARK: - TextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searhTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type somthing"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let cityName = searhTextField.text else {
            return
        }
        
        apiCaller.fetchWeatherBy(cityName)
        
        textField.text = ""
    }
    
}

//MARK: - APICallerDelegate
extension WeatherViewController: APICallerDelegate {
    
    func didUpdateWeaher(weather: WeahterModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)            
        }
    }
    
    func didFailWith(_ error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        apiCaller.fetchWeatherBy(latitude: lat, longitude: lon)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

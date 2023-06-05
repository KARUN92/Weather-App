//
//  Dashboard.swift
//  WeatherApp
//
//  Created by Karun Kumaron 02/06/23.
//

import UIKit
import CoreLocation

class Dashboard: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var viewWeatherOptions: UIView!
    @IBOutlet weak var viewWeather: UIView!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var btnSearchCity: UIButton!
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblWeatherType: UILabel!
    @IBOutlet weak var lblMinimumTemperature: UILabel!
    @IBOutlet weak var lblMaximumTemperature: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var lblPressure: UILabel!
    @IBOutlet weak var lblWindSpeed: UILabel!
    @IBOutlet weak var lblSunriseTime: UILabel!
    @IBOutlet weak var lblSunsetTime: UILabel!
    
    private var locationManager: CLLocationManager?
    private var lastLatitude: Double?
    private var lastLongitude: Double?
    
    private let weatherDataViewModel = WeatherDataViewModel()
    private var weatherModel: WeatherDataModel!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = "Weather"
        
        // Initially hide weather view
        self.viewWeather.isHidden = true
        
        // Check weather User Defaults have data or not
        if let latitude = UserDefaults.standard.value(forKey: "LastLatitude"), let longitude = UserDefaults.standard.value(forKey: "LastLongitude") {
            
            // Hide Weather Options View
            self.viewWeatherOptions.isHidden = true
            
            // Call API to get Weather Data
            let lat = latitude as? Double ?? 0.0
            let long = longitude as? Double ?? 0.0
            self.getWeatherData(WithCoordinates: lat, long: long)
            
        } else {
            // Show Weather Options View
            self.viewWeatherOptions.isHidden = false
        }
        
        setupNavBar()
        setupUI()
        setupLocationManager()
    }
    
    // MARK: - UIButton Action
    // Current Location Button
    @IBAction func btnCurrentLocationClicked(_ sender: Any) {
        locationManager?.requestAlwaysAuthorization()
    }
    
    // Search City Button
    @IBAction func btnSearchCityClicked(_ sender: Any) {
        // Open Search City screen
        self.btnSearchClicked()
    }
    
    
}

// MARK: - Setup
extension Dashboard {
    private func setupNavBar() {
        let rightBarButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(btnSearchClicked))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupUI() {
        btnCurrentLocation.layer.cornerRadius = 6.0
        btnCurrentLocation.layer.masksToBounds = true
        
        btnSearchCity.layer.cornerRadius = 6.0
        btnSearchCity.layer.masksToBounds = true
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    private func updateUI() {
        print(self.weatherModel.name ?? "")
        
        // Hide Weather Options View
        self.viewWeatherOptions.isHidden = true
        self.viewWeather.isHidden = false
        
        viewWeather.backgroundColor = .systemGray6
        
        // Set Data
        lblCity.text = (self.weatherModel.name ?? "") + ", " + (self.weatherModel.sys?.country ?? "")
        lblTime.text = self.dayStringFromTime(unixTime: self.weatherModel.dt ?? 0)
        lblTemperature.text = "\(self.weatherModel.main?.temp ?? 0) C"
        lblWeatherType.text = self.weatherModel.weather?.first?.main
        lblMinimumTemperature.text = "\(self.weatherModel.main?.tempMin ?? 0)"
        lblMaximumTemperature.text = "\(self.weatherModel.main?.tempMax ?? 0)"
        lblHumidity.text = "\(self.weatherModel.main?.humidity ?? 0)%"
        lblPressure.text = "\(self.weatherModel.main?.pressure ?? 0) hPa"
        lblWindSpeed.text = "\(self.weatherModel.wind?.speed ?? 0) kPh"
        lblSunriseTime.text = self.timeStringFromUnixTime(unixTime: self.weatherModel.sys?.sunrise ?? 0)
        lblSunsetTime.text = self.timeStringFromUnixTime(unixTime: self.weatherModel.sys?.sunset ?? 0)
        
        // Load Image
        if let strIcon = self.weatherModel.weather?.first?.icon {
            let strIconURL = Constants.WeatherIconURL.replacingOccurrences(of: "ICONNAME", with: strIcon)
            imageViewIcon.loadImageUsingCacheWithURLString(strIconURL)
        }
    }
    
    func timeStringFromUnixTime(unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))

        // Returns date formatted as 12 hour time.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }

    func dayStringFromTime(unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

// MARK: - Location Methods
extension Dashboard: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            // Authorized, Get user's current location
            locationManager?.startUpdatingLocation()
        } else {
            // Permission Denied
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        // Stop updating location
        locationManager?.stopUpdatingLocation()
        
        // Call API to get Weather Data
        self.getWeatherData(WithCoordinates: location.latitude, long: location.longitude)
        
        // Set Data
        lastLatitude = location.latitude
        lastLongitude = location.longitude
    }
}

// MARK: - Navigation
extension Dashboard {
    @objc func btnSearchClicked() {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchCity") as? SearchCity else {
            return
        }
        viewController.delegate = self
        
        let navCTR = UINavigationController(rootViewController: viewController)
        self.present(navCTR, animated: true)
    }
}

// MARK: - Search City Delegate
extension Dashboard: SearchCityDelegate {
    func selectedCity(_ selectedModel: SearchCityModel) {
        guard let latitude = selectedModel.lat else {
            return
        }
        
        guard let longitude = selectedModel.lon else {
            return
        }
        
        self.getWeatherData(WithCoordinates: latitude, long: longitude)
    }
}

// MARK: - API Call
extension Dashboard {
    private func getWeatherData(WithCoordinates lat: Double, long: Double) {
        // If searching for same coordinates, then return it
        if lastLatitude == lat && lastLongitude == long {
            return
        }
        
        // Show Loading Screen
        LoaderView.sharedInstance.showLoader()
        
        self.weatherDataViewModel.getWeatherData(withCoordinates: lat, longitude: long) { model, error in
            // Hide Loading Screen
            LoaderView.sharedInstance.hideLoader()
            
            if let errorMessage = error {
                // Show Alert
                self.showAlert(withMessage: errorMessage)
            } else {
                // Get Model
                self.weatherModel = model
                
                // Save Coordinates to User Defaults
                UserDefaults.standard.setValue(lat, forKey: "LastLatitude")
                UserDefaults.standard.setValue(long, forKey: "LastLongitude")
                UserDefaults.standard.synchronize()
                
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }
        }
    }
}

// MARK: - Show Alert
extension Dashboard {
    func showAlert(withMessage strMessage: String) {
        let alert = UIAlertController(title: "", message: strMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alert, animated: true)
    }
}


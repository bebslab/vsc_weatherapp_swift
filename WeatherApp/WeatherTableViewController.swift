//
//  WeatherTableViewController.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

import UIKit
import CoreLocation
import DGElasticPullToRefresh
import ReachabilitySwift
import RxReachability
import RxSwift
import GoogleMaps
import GooglePlaces
import PKHUD


class WeatherTableViewController: UITableViewController, GMSAutocompleteViewControllerDelegate {
    
    
    
    // MARK: - Override Functions
    /* General */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkReachability.sharedInstance.isReachable()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherTableViewController.reloadTableViewDataWithDataPull(_:)), name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated_dataPullRequired.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.apiKeyUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherTableViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToTop()
        if UserDefaults.standard.value(forKey: "weatherapp.isInitialLaunch") == nil {
            if(NetworkReachability.sharedInstance.isNetworkAvailable) {
                WeatherService.current.fetchData(success: { (_) in
                    UserDefaults.standard.set(false, forKey: "weatherapp.isInitialLaunch")
                    self.tableView.reloadData()
                }, failureType: { (failure, _) in
                    failure.action()
                })
            } else {
                NetworkReachability.sharedInstance.showBannerKO()
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = NSLocalizedString("WeatherListTVC_NavigationItemTitle", comment: "").uppercased() + " in " + "\(WeatherService.current.favoritedLocation)"
    }
    
    func setupUI(){
        WeatherService.current.temperatureUnit = TemperatureUnit(value: .celsius)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 89/255, green: 200/255, blue: 224/255, alpha: 1.0)
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(red: 51/255, green: 56/255, blue: 92/255, alpha: 1.0)
        //refresh component
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 89/255.0, green: 200/255.0, blue: 224/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.refreshContent()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
    }
    
    
    //MARK: - Tableview delegate
    /* TableView */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 0
        }
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !WeatherService.current.multiLocationWeatherData.isEmpty {
            switch section {
            case 0:
                return NSLocalizedString("WeatherListTVC_TableViewSectionHeader1", comment: "")
            case 1:
                return NSLocalizedString("WeatherListTVC_TableViewSectionHeader2", comment: "")
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !WeatherService.current.multiLocationWeatherData.isEmpty {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !WeatherService.current.multiLocationWeatherData.isEmpty {
            if section == 0 {
                return 1
            } else {
                return WeatherService.current.multiLocationWeatherData.count
                
            }
        }
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !WeatherService.current.multiLocationWeatherData.isEmpty {
            var weatherData: WeatherDTO!
            weatherData = WeatherService.current.multiLocationWeatherData[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            cell.backgroundColorView.layer.cornerRadius = 5.0
            cell.backgroundColorView.layer.backgroundColor = UIColor(red: 82/255, green: 85/255, blue: 113/255, alpha: 1.0).cgColor
            
            cell.cityNameLabel.textColor = .white
            cell.cityNameLabel.font = .preferredFont(forTextStyle: .headline)
            
            cell.temperatureLabel.textColor = .white
            cell.temperatureLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.cloudCoverLabel.textColor = .white
            cell.cloudCoverLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.humidityLabel.textColor = .white
            cell.humidityLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.windspeedLabel.textColor = .white
            cell.windspeedLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.weatherConditionLabel.text! = weatherData.condition
            cell.cityNameLabel.text! = weatherData.cityName
            cell.temperatureLabel.text! = "🌡 \(weatherData.determineTemperatureForUnit())"
            cell.cloudCoverLabel.text! = "☁️ \(weatherData.cloudCoverage)%"
            cell.humidityLabel.text! = "💧 \(weatherData.humidity)%"
            cell.windspeedLabel.text! = "💨 \(weatherData.windspeed) km/h"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            cell.noticeLabel.text! = NSLocalizedString("WeatherListTVC_AlertNoData", comment: "")
            cell.backgroundColorView.layer.cornerRadius = 5.0
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 89/255, green: 200/255, blue: 224/255, alpha: 1.0)
    }
    /* Deinitializer */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Helper Functions
    
    /* General */
    
    @objc private func refreshContent() {
        if(NetworkReachability.sharedInstance.isNetworkAvailable) {
            WeatherService.current.fetchData(success: { (_) in
                self.tableView.dg_stopLoading()
            }) { (failure, _) in
                failure.action()
            }
        } else {
            tableView.dg_stopLoading()
            NetworkReachability.sharedInstance.showBannerKO()
        }
    }
    
    @objc func reloadTableViewDataWithDataPull(_ notification: Notification) {
        if(NetworkReachability.sharedInstance.isNetworkAvailable) {
            HUD.show(.progress)
            WeatherService.current.fetchData(success: { (_) in
                HUD.hide(afterDelay: 0.5)
                UserDefaults.standard.set(false, forKey: "weatherapp.isInitialLaunch")
                self.tableView.reloadData()
            }) { (failure, _) in
                HUD.hide()
                failure.action()
            }
        } else {
            NetworkReachability.sharedInstance.showBannerKO()
        }
    }
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0 , section: 0)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    // MARK: - Navigation Segues
    
    @IBAction func didTapSettingsButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.navigationBar.tintColor = .white
        
        let rootController = self as UITableViewController
        rootController.present(destinationNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func didTapInfoButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "InfoTVC") as! InfoTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.navigationBar.tintColor = .white
        
        let rootController = self as UITableViewController
        rootController.present(destinationNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func SearchTapButton(_ sender: UIBarButtonItem) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        autoCompleteController.primaryTextHighlightColor = UIColor.purple
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autoCompleteController.autocompleteFilter = filter
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        guard let placeName = place.addressComponents?[0].name else {
            return
        }
        print("PLACE SELECTED --> \(placeName)")
        WeatherService.current.favoritedLocation = placeName
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE --> \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
}


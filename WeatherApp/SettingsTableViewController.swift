//
//  SettingsTableViewController.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class SettingsTableViewController: UITableViewController, GMSAutocompleteViewControllerDelegate {
    
    // MARK: - Override Functions
    
    /* General */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.apiKeyUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func setupUI() {
        navigationItem.title = NSLocalizedString("SettingsTVC_NavigationBarTitle", comment: "").uppercased()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsTableViewController.didTapDoneButton(_:)))
        self.navigationController?.navigationBar.tintColor = UIColor(red: 89/255, green: 200/255, blue: 224/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 51/255, green: 56/255, blue: 92/255, alpha: 1.0)
        
    }
    
    //MARK: - Tableview delegate
    /* TableView */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let autoCompleteController = GMSAutocompleteViewController()
            autoCompleteController.delegate = self
            let filter = GMSAutocompleteFilter()
            filter.type = .city
            autoCompleteController.autocompleteFilter = filter
            self.present(autoCompleteController, animated: true, completion: nil)
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsInputTVC") as! SettingsInputTableViewController
            destinationViewController.mode = .enterAPIKey
            navigationController?.pushViewController(destinationViewController, animated: true)
        case 2:
            WeatherService.current.temperatureUnit = TemperatureUnit(rawValue: indexPath.row)
            tableView.reloadData()
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("SettingsTVC_SectionTitle1", comment: "")
        case 1:
            return NSLocalizedString("SettingsTVC_SectionTitle2", comment: "")
        case 2:
            return NSLocalizedString("SettingsTVC_SectionTitle4", comment: "")
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return TemperatureUnit.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.accessoryType = .none
        cell.backgroundColor = UIColor(red: 82/255, green: 85/255, blue: 113/255, alpha: 1.0)
        cell.contentLabel.textColor = UIColor.white
        switch indexPath.section {
        case 0:
            cell.contentLabel.text! = WeatherService.current.favoritedLocation
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            cell.contentLabel.text! = UserDefaults.standard.value(forKey: "weatherappOpenWeatherMapApiKey") as! String
            cell.accessoryType = .disclosureIndicator
            return cell
        case 2:
            let temperatureUnit = TemperatureUnit(rawValue: indexPath.row)
            cell.contentLabel.text! = temperatureUnit.stringValue
            if temperatureUnit.stringValue == WeatherService.current.temperatureUnit.stringValue {
                cell.accessoryType = .checkmark
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    
    // MARK: - Button Interaction
    
    @objc private func didTapDoneButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        guard let placeName = place.addressComponents?[0].name else {
            return
        }
        print("PLACE AUTO COMPLETE --> \(placeName)")
        WeatherService.current.favoritedLocation = placeName
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE --> \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
}

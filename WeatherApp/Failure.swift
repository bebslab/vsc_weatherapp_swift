//
//  Failure.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 23/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

import UIKit

/*
 This class refer all failure posssible and return by the server
 */


public enum FailureReason:Int {
    case NoConnection = 888
    case NotFound = 404
    case Other = 999
    
    
    public func printable() -> String {
        switch self {
        case .NoConnection:
            return "There is a connecton error"
        case .NotFound:
            return "No result. Please change your place request..."
        case .Other:
            return "Unknown error"
        }
    }
    
    public func action() {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        _ = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            print("User did click Ok button")
        }
        
        _ = UIAlertAction(title: "Disconnect", style: .cancel) { (action) in
            print("User did click Disconnect button")
        }
        
        let shieeeetAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            print("Unknown error...")
        }
        
        switch self {
            
        case .NoConnection:
            alert.title = "Connection error"
            alert.message = "Please verify your internet connection."
            alert.addAction(shieeeetAction)
            showAlert(alert: alert)
        case .NotFound:
            alert.title = "Error server"
            alert.message = "No result. Please change your place request..."
            alert.addAction(shieeeetAction)
            showAlert(alert: alert)
            
        default:
            return
        }
        
    }
    
    private func showAlert(alert: UIAlertController) {
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
}

public typealias FailureHandler = (_ reason:FailureReason, _ error: NSError) -> ()



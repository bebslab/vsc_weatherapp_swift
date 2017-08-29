//
//  Reachability.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 24/08/2017.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import ReachabilitySwift
import RxReachability
import RxSwift
import NotificationBannerSwift

public class NetworkReachability {
    
    public static let sharedInstance = NetworkReachability()
    let disposeBag = DisposeBag()
    var isNetworkAvailable = true
    
    //MARK: -Check network reachability
    
    func isReachable() {
        Reachability.rx.reachabilityChanged
            .subscribe(onNext: { (reachability) in
                print("Reachability changed: \(reachability.currentReachabilityStatus)")
                
            }, onError: { (error) in
                print("Error reachability -> \(error as NSError)")
            }, onCompleted: {
                //something to do
            }) {
                //somrthing to do when disposed
            }
            .addDisposableTo(disposeBag)
        
        
        Reachability.rx.status
            .subscribe(onNext: { (status) in
                print("Reachability status changed: \(status.description)")
                
            }, onError: { (error) in
                print("Error reachability -> \(error as NSError)")
            }, onCompleted: {
                //something to do
            }) {
                //somrthing to do when disposed
            }
            .addDisposableTo(disposeBag)
        
        
        Reachability.rx.isReachable
            .subscribe(onNext: { (isReachable) in
                print("Is reachable: \(isReachable.description)")
            }, onError: { (error) in
                print("Error reachability -> \(error as NSError)")
            }, onCompleted: {
                //something to do
            }) {
                //somrthing to do when disposed
            }
            .addDisposableTo(disposeBag)
        
        
        Reachability.rx.isConnected
            .subscribe(onNext: {
                print("Is connected")
                self.isNetworkAvailable = true
                self.showBannerOK()
            })
            .addDisposableTo(disposeBag)
        
        Reachability.rx.isDisconnected
            .subscribe(onNext: {
                print("Is disconnected")
                self.isNetworkAvailable = false
                self.showBannerKO()
            })
            .addDisposableTo(disposeBag)
    }
    
    func showBannerOK() {
        let banner = StatusBarNotificationBanner(title: NSLocalizedString("WeatherListTVC_AlertBanner_Network_OK", comment: ""), style: .success)
        banner.show()
    }
    
    func showBannerKO() {
        let banner = StatusBarNotificationBanner(title: NSLocalizedString("WeatherListTVC_AlertBanner_Network_KO", comment: ""), style: .danger)
        banner.show()
    }
    
}

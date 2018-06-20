//
//  ProxyDelegate.swift
//  Events Center
//
//  Created by De biasi, Anna (A.) on 6/19/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit
import SmartDeviceLink

// Sport -> Menu ... Phone -> TDK ... MainViewController
extension ProxyManager : ChoseSportDelegate{
    func didRequestMenuItems(event: String){
        var num = 0
        switch event{
        case "nutrition":
            num = 1
        case "soccer":
            num = 2
        case "golf":
            num = 3
        default:
            num = 0
        }
        makeCustomMenu(activity: event, num: num)
    }
}

// Back Button -> Sport || Menu -> Detail ... Phone -> TDK ... ViewController
extension ProxyManager : ChoseEventDelegate{
//    hmiLevel(.none, didChangeToLevel: .full)
    func didGoBack(){
            setUp()
    }
    func choseEventPhone(activity: String, jsonData: [APIStruct], identifier: Int){
        createAlert(activity: activity, jsonData: jsonData, identifier: identifier)
    }
}

// Sport -> Menu ... TDK -> Phone
extension MainViewController : ClickedSportDelegate{
    func clickedSport(str: String) {
    performSegue(withIdentifier: str, sender: Int(1))
    }
}

// Menu -> Detail ... TDK -> Phone
extension ViewController: ClickedEventDelegate{
    func clickedEventTDK(num:Int) {
        performSegue(withIdentifier: "labeling", sender: num)
    }
}







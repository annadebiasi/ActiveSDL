//
//  ProxyExtension.swift
//  Events Center
//
//  Created by De biasi, Anna (A.) on 6/19/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit
import SmartDeviceLink

// sport button is pressed on TDK
protocol ClickedSportDelegate: class {
    func clickedSport(str:String)
}

// event button is pressed on TDK
protocol ClickedEventDelegate: class {
    func clickedEventTDK(num:Int)
}

// Menu button is pressed on TDK
protocol ClickedMenu : class {
    func clickedMenuTDK()
}

extension ProxyManager: SDLManagerDelegate {
    
    func managerDidDisconnect() {
        print("Manager disconnected!")
    }
    
    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        // print("Went from HMI level \(oldLevel) to HMI level \(newLevel)")
        if(oldLevel == .none && newLevel == .full){
            // Defines the template layout
            let display = SDLSetDisplayLayout(predefinedLayout: .tilesWithGraphic)
            // Sending request to display layout
            sdlManager.send(request: display) { (request, response, error) in
                if response?.resultCode == .success {
                    // The template has been set successfully
                    self.setUp()
                }
            }
        }
    }
    
//Sets up Nutrition, Golf, and soccer Buttons
    func setUp(){
        let display = SDLSetDisplayLayout(predefinedLayout: .tilesWithGraphic)
        // Sending request to display layout
        sdlManager.send(request: display) { (request, response, error) in
            if response?.resultCode == .success {
                self.sdlManager.screenManager.beginUpdates()
                // nutrition button
                let button1 = SDLSoftButtonObject(name: "Nutrition", state: SDLSoftButtonState.init(stateName: "Normal", text: "Nutrition", image: UIImage(named: "nutrition")!), handler: { (press, event) in
                    guard let buttonPress1 = press else { return }
                    switch buttonPress1.buttonPressMode {
                    case .short:
                        self.clickedSportDelegate?.clickedSport(str:"Nutrition")
                    default:
                        return
                        
                    }
                })
                
                // soccer button
                let button2 = SDLSoftButtonObject(name: "Soccer", state: SDLSoftButtonState.init(stateName: "Normal", text: "Soccer", image: UIImage(named: "soccer")!), handler: { (press, event) in
                    guard let buttonPress2 = press else { return }
                    switch buttonPress2.buttonPressMode {
                    case .short:
                        self.clickedSportDelegate?.clickedSport(str: "Soccer")
                    default:
                        return
                    }
                })
                
                // golf button
                let button3 = SDLSoftButtonObject(name: "Golf", state: SDLSoftButtonState.init(stateName: "Normal", text: "Golf", image: UIImage(named: "golf")!), handler: { (press, event) in
                    guard let buttonPress3 = press else { return }
                    switch buttonPress3.buttonPressMode {
                    case .short:
                        self.clickedSportDelegate?.clickedSport(str: "Golf")
                    default:
                        return
                    }
                })
                
                // initializes the screen with the array of three buttons
                self.sdlManager?.screenManager.softButtonObjects = [button1, button2, button3]
                
                // puts the primary graphic on the screen
                self.sdlManager.screenManager.primaryGraphic = SDLArtwork.init(image: UIImage(named: "active")!, persistent: true, as: .PNG)
                
                // ends all screen updates
                self.sdlManager.screenManager.endUpdates { (error) in
                   return
                }
            }
        }
    }
    
    // Makes list of Events
    func makeCustomMenu(activity: String, num : Int, jsonData: [APIStruct]){
        var organizationNames = [String]()
        for data in jsonData {
            if(!organizationNames.contains((data).organization.organizationName)) {
                organizationNames.append(data.organization.organizationName)
            }
        }
        var count = 25
        var requestList = [SDLChoice]()
        if(num == 3){
            count = 75
        }else if(num == 2){
            count = 50
        }
        for (index, organizationName) in  organizationNames.enumerated() {
            requestList.append(SDLChoice(id: (UInt16(index + count)), menuName: "\(organizationName)", vrCommands: ["\(organizationName)"]))
        }
        var createRequest: SDLCreateInteractionChoiceSet
        if(!list.keys.contains(num)){
            createRequest = SDLCreateInteractionChoiceSet(id: UInt32(num), choiceSet: requestList)
            list[num] = createRequest
            self.sdlManager.send(request: createRequest) { (request, response, error) in
                if response?.resultCode == .success {
                    var performInteraction : SDLPerformInteraction
                    if(!self.list2.keys.contains(num)){
                
                        performInteraction = SDLPerformInteraction(initialPrompt: "\(activity) Events", initialText: "\(activity) Events", interactionChoiceSetID: UInt16(num))
                        self.list2[num] = performInteraction
                    }
                    performInteraction = self.list2[num]!
                    performInteraction.interactionMode = .manualOnly
                    performInteraction.interactionLayout = .listOnly
                    self.sdlManager.send(request: performInteraction) { (request, response, error) in
                        let performInteractionResponse = response as! SDLPerformInteractionResponse
                        // Wait for user's selection or for timeout
                        if (performInteractionResponse.resultCode == SDLResult.timedOut || performInteractionResponse.resultCode == SDLResult.cancelRoute || performInteractionResponse.resultCode == .aborted ){
                        }else if (performInteractionResponse.resultCode == .success){
                            // The custom menu timed out before the user could select an item
                            var choiceId = performInteractionResponse.choiceID as! Int
                            print("CHOICE ", choiceId)
                            print("ORG CNT ", organizationNames.count)
                            choiceId -= count
                            if(choiceId <= organizationNames.count){
                                // The user selected an item in the custom menu
                                self.clickedEventDelegate?.clickedEventTDK(num: choiceId)
                                // self.createAlert(activity: activity, jsonData: jsonData, identifier: choiceId)
                                self.createList(activity: activity, jsonData: jsonData, identifier: choiceId)
                            }
                        }
                    }
                }
            }
        }else if (self.list2.keys.contains(num)){
            let performInteraction = self.list2[num]!
            performInteraction.interactionMode = .manualOnly
            performInteraction.interactionLayout = .listOnly
            self.sdlManager.send(request: performInteraction) { (request, response, error) in
                let performInteractionResponse = response as! SDLPerformInteractionResponse
                // Wait for user's selection or for timeout
                if (performInteractionResponse.resultCode == SDLResult.timedOut || performInteractionResponse.resultCode == SDLResult.cancelRoute || performInteractionResponse.resultCode == .aborted ){
                }else if (performInteractionResponse.resultCode == .success){
                    // The custom menu timed out before the user could select an item
                    var choiceId = performInteractionResponse.choiceID as! Int
                    choiceId -= count
                    if(choiceId <= organizationNames.count){
                        // The user selected an item in the custom menu
                        self.clickedEventDelegate?.clickedEventTDK(num: choiceId)
                        // self.createAlert(activity: activity, jsonData: jsonData, identifier: choiceId)
                        self.createList(activity: activity, jsonData: jsonData, identifier: choiceId)
                    }
                }
            }
        }
    }
    
    func createList(activity : String, jsonData: [APIStruct], identifier: Int){
        let display = SDLSetDisplayLayout(predefinedLayout: .nonMedia) //textAndSoftButtonsWithGraphic
        // Sending request to display layout
        sdlManager.send(request: display) { (request, response, error) in
            if response?.resultCode == .success {
                // The template has been set successfully
                self.sdlManager.screenManager.beginUpdates()
                
                self.sdlManager.screenManager.textField1 = "\((jsonData[identifier]).place.addressLine1Txt), \((jsonData[identifier]).place.cityName) \((jsonData[identifier]).place.stateProvinceCode)"
                self.sdlManager.screenManager.textField2 = "Sales Start Date: \(String(getProperDate(from:(jsonData[identifier]).salesStartDate) ?? "N/A"))"
                self.sdlManager.screenManager.textField3 = "Sales End Date: \(String( getProperDate(from:(jsonData[identifier]).salesEndDate) ?? "N/A"))"
                self.sdlManager.screenManager.textField4 = "\((jsonData[identifier]).organization.primaryContactPhone)"
                
                self.sdlManager.screenManager.primaryGraphic = SDLArtwork.init(image: UIImage(named: activity.lowercased())!, persistent: true, as: .PNG)
                
                
                let callButton = SDLSoftButtonState(stateName:  "Normal", text: "Call", image: UIImage(named: "phone"))
                let directionsButton = SDLSoftButtonState(stateName:  "Normal", text: "Directions", image: UIImage(named: "directions"))
                let backButton = SDLSoftButtonState(stateName:  "Normal", text: "Back", image: nil)

                
                let calButton = SDLSoftButtonObject(name:  "Call \((jsonData[identifier]).organization.primaryContactPhone)", state: callButton, handler: { (press, event) in
                    guard let buttonPress2 = press else { return }
                    switch buttonPress2.buttonPressMode {
                    case .short:
                        let number = "7345760544"
                        self.callNumber(number : number)
                    default:
                        print("Error! call")
                    }
                })

                let dirButton = SDLSoftButtonObject(name: "Directions", state: directionsButton, handler: { (press, event) in
                    guard let buttonPress2 = press else { return }
                    switch buttonPress2.buttonPressMode {
                    case .short:
                        self.getDirections(data : jsonData[identifier])
                    default:
                        print("Error! directions")
                    }
                })
                
                let bacButton = SDLSoftButtonObject(name: "Back", state: backButton, handler: { (press, event) in
                    guard let buttonPress2 = press else { return }
                    switch buttonPress2.buttonPressMode {
                    case .short:
                        self.setUp()
                    default:
                        return
                    }
                })
                self.sdlManager?.screenManager.softButtonObjects = [calButton, dirButton, bacButton]
                
                self.sdlManager.screenManager.endUpdates { (error) in
                    if error != nil {
                       return
                    } else {
                        return
                    }
                }
            }
        }
    }

    
    func callNumber(number : String){
//        var isPhoneCallSupported = false
//        if let hmiCapabilities = self.sdlManager.registerResponse?.hmiCapabilities, let phoneCallsSupported = hmiCapabilities.phoneCall?.boolValue {
//            isPhoneCallSupported = phoneCallsSupported
//            if(!isPhoneCallSupported){
//                print("Phone call is not supported")
//            }
//        }
        
        sdlManager.start { (success, error) in
            if !success {
                //print("SDL errored starting up: \(error.debugDescription)")
                return
            }
        }
        
        let dialNumber = SDLDialNumber()
        dialNumber.number = "7345760544"
        
        sdlManager.send(request: dialNumber) { (request, response, error) in
            guard let response = response as? SDLDialNumberResponse else { return }
            
            if let error = error {
                print("Encountered Error sending DialNumber: \(error)")
                return
            }
    
            if response.resultCode != .success {
                if response.resultCode == .rejected {
                    print("DialNumber was rejected. Either the call was sent and cancelled or there is no device connected")
                } else if response.resultCode == .disallowed {
                    print("Your app is not allowed to use DialNumber")
                } else {
                    print("Some unknown error has occured!")
                }
                return
            }
        }
    }
    
    func getDirections(data : APIStruct){
        
        //        var isNavigationSupported = false
        //        if let hmiCapabilities = self.sdlManager.registerResponse?.hmiCapabilities, let navigationSupported = hmiCapabilities.navigation?.boolValue {
        //            isNavigationSupported = navigationSupported
        //            print(" T OR F  " , isNavigationSupported)
        //        }
        
        sdlManager.start { (success, error) in
            if !success {
                print("SDL errored starting up: \(error.debugDescription)")
                return
            }
        }
        
        let sendLocation = SDLSendLocation(longitude: -97.380967, latitude: 42.877737, locationName: data.organization.organizationName, locationDescription: "Western United States", address: ["\(data.place.addressLine1Txt), \(data.place.cityName), \(data.place.stateProvinceCode)"], phoneNumber: nil, image: nil)
        sdlManager.send(request: sendLocation) { (request, response, error) in
            guard let response = response as? SDLSendLocationResponse else { return }
            if let error = error {
                print("Encountered Error sending SendLocation: \(error)")
                return
            }
            if response.resultCode != .success {
                if response.resultCode == .invalidData {
                    print("SendLocation was rejected. The request contained invalid data.")
                } else if response.resultCode == .disallowed {
                    print("Your app is not allowed to use SendLoUcation")
                } else {
                    print("Some unknown error has occured!")
                }
                return
            }
        }
    }
}


//
//func createAlert(activity: String, jsonData: [APIStruct], identifier: Int){
//    let address = " \((jsonData[identifier]).place.addressLine1Txt), \((jsonData[identifier]).place.cityName) \((jsonData[identifier]).place.stateProvinceCode)"
//    let alert = SDLAlert(alertText1: activity , alertText2: address , alertText3: "Sales Start Date: \(String(getProperDate(from:(jsonData[identifier]).salesStartDate) ?? "N/A")), End Date: \(String( getProperDate(from:(jsonData[identifier]).salesEndDate) ?? "N/A"))")
//
//    // Maximum time alert appears before being dismissed
//    // Timeouts are must be between ]]3-10 seconds
//    // Timeouts may not work when soft buttons are also used in the alert
//    alert.duration = 5000 as NSNumber & SDLInt
//
//    // A progress indicator (e.g. spinning wheel or hourglass)
//    // Not all head units support the progress indicator
//    alert.progressIndicator = true as NSNumber & SDLBool
//
//    // Text-to-speech
//    //alert.ttsChunks = SDLTTSChunk.textChunks(from: "hello")
//
//    // Special tone played before the tts is spoken
//    alert.playTone = true as NSNumber & SDLBool
//
//    // Soft buttons
//    let callNumber = SDLSoftButton()
//    callNumber.text = "Call \((jsonData[identifier]).organization.primaryContactPhone)"
//    callNumber.type = .text
//    callNumber.softButtonID = 15 as NSNumber & SDLInt
//    callNumber.handler = { (buttonPress, buttonEvent) in
//        guard buttonPress != nil else { return }
//        // create a custom action for the selected button
//        let number = "7345760544"
//        self.callNumber(number : number)
//    }
//    let getDirections = SDLSoftButton()
//    getDirections.text = "Directions"
//    getDirections.type = .text
//    getDirections.softButtonID = 14 as NSNumber & SDLInt
//    getDirections.handler = { (buttonPress, buttonEvent) in
//        guard buttonPress != nil else { return }
//        // create a custom action for the selected button
//        self.getDirections(data : jsonData[identifier])
//    }
//    let menu = SDLSoftButton()
//    menu.text = "Menu"
//    menu.type = .text
//    menu.softButtonID = 16 as NSNumber & SDLInt
//    menu.handler = { (buttonPress, buttonEvent) in
//        guard let _ = buttonPress else { return }
//        self.clickedMenu?.clickedMenuTDK()
//    }
//    alert.softButtons = [getDirections, callNumber, menu]
//    // Send the alert
//    sdlManager.send(request: alert) { (request, response, error) in
//        if response?.resultCode == .success {
//            // alert was dismissed successfully
//            let deleteRequest = SDLDeleteInteractionChoiceSet(id: UInt32(identifier))
//            self.sdlManager.send(request: deleteRequest) { (request, response, error) in
//                if response?.resultCode == .success {
//                      return
//                }
//            }
//        }
//}

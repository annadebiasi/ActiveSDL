//
//  ProxyExtension.swift
//  Events Center
//
//  Created by De biasi, Anna (A.) on 6/19/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit
import SmartDeviceLink

protocol ClickedSportDelegate: class {
    func clickedSport(str:String)
}

protocol ClickedEventDelegate: class {
    func clickedEventTDK(num:Int)
}

//MARK: SDLManagerDelegate
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
    
//Sets up Nutrition,Golf,and soccer Buttons
    func setUp(){
        sdlManager.screenManager.beginUpdates()
        // nutrition button
        let button1 = SDLSoftButtonObject(name: "Nutrition", state: SDLSoftButtonState.init(stateName: "Normal", text: "Nutrition", image: UIImage(named: "nutrition")!), handler: { (press, event) in
            guard let buttonPress1 = press else { return }
            switch buttonPress1.buttonPressMode {
            case .short:
                self.clickedSportDelegate?.clickedSport(str:"nutrition")
                self.makeCustomMenu(activity: "Nutrition", num: 1)
            default:
                print("Error! nutrition")
            }
        })
        
        // soccer button
        let button2 = SDLSoftButtonObject(name: "Soccer", state: SDLSoftButtonState.init(stateName: "Normal", text: "Soccer", image: UIImage(named: "soccer")!), handler: { (press, event) in
            
            guard let buttonPress2 = press else { return }
            switch buttonPress2.buttonPressMode {
            case .short:
                self.clickedSportDelegate?.clickedSport(str: "soccer")
                self.makeCustomMenu(activity: "Soccer", num: 2)
            default:
                print("Error! soccer")
            }
        })
        
        // golf button
        let button3 = SDLSoftButtonObject(name: "Golf", state: SDLSoftButtonState.init(stateName: "Normal", text: "Golf", image: UIImage(named: "golf")!), handler: { (press, event) in
            guard let buttonPress3 = press else { return }
            switch buttonPress3.buttonPressMode {
            case .short:
                self.clickedSportDelegate?.clickedSport(str: "golf")
                self.makeCustomMenu(activity: "Golf" , num: 3)
            //  self.delegate?.didRequestMenuItems(event: "golf", callBack: {self.makeCustomMenu(activity: "Golf" , num: 3)})
            default:
                print("Error! golf")
            }
        })
        // initializes the screen with the array of three buttons
        sdlManager?.screenManager.softButtonObjects = [button1, button2, button3]
        
        // puts the primary graphic on the screen
        sdlManager.screenManager.primaryGraphic = SDLArtwork.init(image: UIImage(named: "active")!, persistent: true, as: .PNG)
        
        // ends all screen updates
        sdlManager.screenManager.endUpdates { (error) in
            if error != nil {
                print("Error Updating UI")
            } else {
                print("Update to UI was Successful")
            }
        }
    }
    
// Makes list of Events
    func makeCustomMenu(activity: String, num : Int){
        getJson(str: activity) { jsonData in
            var organizationNames = [String]()
            var index = 0
            for _ in jsonData {
                if(!organizationNames.contains((jsonData[index]).organization.organizationName)){
                    organizationNames.append((jsonData[index]).organization.organizationName)
                }
                index += 1
            }
            var count = 0
            var requestList = [SDLChoice]()
            for _ in  0..<organizationNames.count{
                requestList.append(SDLChoice(id: (UInt16(count)), menuName: "\(organizationNames[count])", vrCommands: ["\(organizationNames[count])"]))
                count += 1
            }
            let createRequest = SDLCreateInteractionChoiceSet(id: UInt32(num), choiceSet: requestList)
            self.sdlManager.send(request: createRequest) { (request, response, error) in
                if response?.resultCode == .success {
                    let performInteraction = SDLPerformInteraction(initialPrompt: "\(activity) Events", initialText: "\(activity) Events", interactionChoiceSetID: UInt16(num))
                    performInteraction.interactionMode = .manualOnly
                    performInteraction.interactionLayout = .listOnly
                    performInteraction.timeout = 15000 as NSNumber & SDLInt
                    self.sdlManager.send(request: performInteraction) { (request, response, error) in
                        let performInteractionResponse = response as! SDLPerformInteractionResponse
                        // Wait for user's selection or for timeout
                        if (performInteractionResponse.resultCode == SDLResult.timedOut || performInteractionResponse.resultCode == SDLResult.cancelRoute || performInteractionResponse.resultCode == .aborted ){ 
                            let deleteRequest = SDLDeleteInteractionChoiceSet(id: UInt32(num))
                            self.sdlManager.send(request: deleteRequest) { (request, response, error) in
                                if response?.resultCode == .success {
                                }
                            }
                        }else if (performInteractionResponse.resultCode == .success){
                            // The custom menu timed out before the user could select an item
                            let choiceId = performInteractionResponse.choiceID as! Int
                            // The user selected an item in the custom menu
                            self.clickedEventDelegate?.clickedEventTDK(num: choiceId)
                            self.createAlert(activity: activity, jsonData: jsonData, identifier: choiceId)
                           
                        }
                    }
                }
            }
        }
    }
    
    func createAlert(activity: String, jsonData: [APIStruct], identifier: Int){
      // print( "IDENT ", identifier , " ", jsonData.count)
        let address = " \((jsonData[identifier]).place.addressLine1Txt), \((jsonData[identifier]).place.cityName) \((jsonData[identifier]).place.stateProvinceCode)"
        let alert = SDLAlert(alertText1: activity , alertText2: address , alertText3: "Sales Start Date: \(String(getProperDate(from:(jsonData[identifier]).salesStartDate) ?? "N/A")), End Date: \(String( getProperDate(from:(jsonData[identifier]).salesEndDate) ?? "N/A"))")
        
        // Maximum time alert appears before being dismissed
        // Timeouts are must be between ]]3-10 seconds
        // Timeouts may not work when soft buttons are also used in the alert
        alert.duration = 5000 as NSNumber & SDLInt
        
        // A progress indicator (e.g. spinning wheel or hourglass)
        // Not all head units support the progress indicator
        alert.progressIndicator = true as NSNumber & SDLBool
        
        // Text-to-speech
        //alert.ttsChunks = SDLTTSChunk.textChunks(from: "hello")
        
        // Special tone played before the tts is spoken
        alert.playTone = true as NSNumber & SDLBool
        
        // Soft buttons
        let callNumber = SDLSoftButton()
        callNumber.text = "Call \((jsonData[identifier]).organization.primaryContactPhone)"
        callNumber.type = .text
        callNumber.softButtonID = 15 as NSNumber & SDLInt
        callNumber.handler = { (buttonPress, buttonEvent) in
            guard buttonPress != nil else { return }
            // create a custom action for the selected button
            let number = "7345760544"
            self.callNumber(number : number)
        }
        let getDirections = SDLSoftButton()
        getDirections.text = "Directions"
        getDirections.type = .text
        getDirections.softButtonID = 14 as NSNumber & SDLInt
        getDirections.handler = { (buttonPress, buttonEvent) in
            guard buttonPress != nil else { return }
            // create a custom action for the selected button
            self.getDirections(data : jsonData[identifier])
        }
        let menu = SDLSoftButton()
        menu.text = "Menu"
        menu.type = .text
        menu.softButtonID = 16 as NSNumber & SDLInt
        menu.handler = { (buttonPress, buttonEvent) in
            guard let _ = buttonPress else { return }
            // create a custom action for the selected button
            // print("PRESS : ", press)
        }
        
        alert.softButtons = [getDirections, callNumber, menu]
        
        // Send the alert
        sdlManager.send(request: alert) { (request, response, error) in
            if response?.resultCode == .success {
                // alert was dismissed successfully
                let deleteRequest = SDLDeleteInteractionChoiceSet(id: UInt32(identifier))
                self.sdlManager.send(request: deleteRequest) { (request, response, error) in
                    if response?.resultCode == .success {
                        // print("The custom menu was deleted successfully")
                    }
                }
                // print("alert was dismissed successfully")
            }else{
                print("alert not successful")
                print("ERROR  ", error!)
            }
        }
    }
    
    func callNumber(number : String){
        var isPhoneCallSupported = false
        if let hmiCapabilities = self.sdlManager.registerResponse?.hmiCapabilities, let phoneCallsSupported = hmiCapabilities.phoneCall?.boolValue {
            isPhoneCallSupported = phoneCallsSupported
            if(!isPhoneCallSupported){
                print("Phone call is not supported")
            }
        }
        
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
            // Successfully sent!
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
                    print("Your app is not allowed to use SendLocation")
                } else {
                    print("Some unknown error has occured!")
                }
                return
            }
            
            // Successfully sent!
        }
    }
}

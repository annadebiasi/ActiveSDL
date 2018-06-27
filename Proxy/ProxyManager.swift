//
//  ProxyManager.swift
//  TestSDL
//
//  Created by De biasi, Anna (A.) on 6/8/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit
import SmartDeviceLink


class ProxyManager: NSObject {
        
    private let appName = "EventsCenter" //"SyncProxyTester"
    private let appId =  "2274280318" //"883259982"
    
    // Manager
    public var sdlManager: SDLManager!
    
    // Singleton
    static let sharedManager = ProxyManager()
    
    var clickedSportDelegate: ClickedSportDelegate?
    var clickedEventDelegate: ClickedEventDelegate?
    var clickedMenu: ClickedMenu?
    var list = [Int:SDLCreateInteractionChoiceSet]()
    var list2 = [Int:SDLPerformInteraction]()
    
    private override init() {
        super.init()
        
        //disabling the lock screen
        SDLLockScreenConfiguration.disabled()
        
        // Used for USB Connection
        // let lifecycleConfiguration = SDLLifecycleConfiguration(appName: appName, appId: appId)
        
        // Used for TCP/IP Connection
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: appName, appId: appId, ipAddress: "19.32.136.250", port: 12345)
        
        // App icon image
        if let appImage = UIImage(named: "AppIcon") {
            let appIcon = SDLArtwork(image: appImage, name: "AppIcon", persistent: true, as: .PNG /* or .PNG */)
            lifecycleConfiguration.appIcon = appIcon
        }
        
        // Short name for app
        lifecycleConfiguration.shortAppName = "EC"
       
        // Type of App created
        lifecycleConfiguration.appType = .information
        
        //
        let configuration = SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: .enabled(), logging: .default())
        
        // configures
        sdlManager = SDLManager(configuration: configuration, delegate: self)
        
    }
    
    func connect() {
        // Start watching for a connection with an SDL Core
        sdlManager.start { (success, error) in
            if success {
                // Your app has successfully connected with the SDL Core
            }else{
                print("did not connect")
            }
        }
    }
}



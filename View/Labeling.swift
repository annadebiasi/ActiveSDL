//
//  ViewController.swift
//  TestSDL
//
//  Created by De biasi, Anna (A.) on 6/8/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit

protocol LabelingBack : class {
    func wentBack(str: String)
}


class Labeling: UIViewController {
    
    var labelingBack : LabelingBack!
    var apiStruct: APIStruct?
    var str : String?
    
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelFour: UILabel!
    @IBOutlet weak var labelFive: UILabel!
    @IBOutlet weak var labelSix: UILabel!
    @IBOutlet weak var labelSeven: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        
        let textSix = apiStruct!.assetDescriptions.isEmpty ? "Description Unavailable" : apiStruct!.assetDescriptions[0].description
        
        labelSix.text = textSix.htmlToString
        labelSix.numberOfLines = 0
        labelSix.adjustsFontSizeToFitWidth = true
        
        labelOne.text = apiStruct!.organization.organizationName.isEmpty ? "Organization Unavailable" : apiStruct!.organization.organizationName
        labelOne.numberOfLines = 0
        labelOne.adjustsFontSizeToFitWidth = true

        labelTwo.text = apiStruct!.assetPrices.isEmpty ? "Price Unavailable" : "Price: $\(String(apiStruct!.assetPrices[0].priceAmt))"
        labelTwo.numberOfLines = 0
        labelTwo.adjustsFontSizeToFitWidth = true

        labelFour.text = apiStruct!.place.addressLine1Txt.isEmpty || apiStruct!.place.stateProvinceCode.isEmpty ||  apiStruct!.place.cityName.isEmpty ? "Address Unavailable" : "Address: \(String(apiStruct!.place.addressLine1Txt))\n \(apiStruct!.place.stateProvinceCode), \(apiStruct!.place.cityName)"
        labelFour.numberOfLines = 0
        labelFour.adjustsFontSizeToFitWidth = true
        let endLabel =  apiStruct!.salesEndDate.isEmpty ? "Sales End Date Unavailable" :  "Sales End Date: \((getProperDate(from: apiStruct!.salesEndDate))!)"
        labelFive.text = apiStruct!.organization.primaryContactPhone.isEmpty ? "Contact Unavailable" : "Contact Number: \(String(apiStruct!.organization.primaryContactPhone))"
        labelFive.numberOfLines = 0
        labelFive.adjustsFontSizeToFitWidth = true
        
        labelSeven.text = apiStruct!.salesStartDate.isEmpty ? "Sales Start Date Unavailable" : "Sales Start Date: \((getProperDate(from: apiStruct!.salesStartDate))!)  \n \(endLabel)"
        labelSeven.numberOfLines = 0
        labelSeven.adjustsFontSizeToFitWidth = true
    }
    func back(sender: UIBarButtonItem) {
        labelingBack = ProxyManager.sharedManager
        labelingBack.wentBack(str:str!)
        print("Went back from labeling")
    }
    
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}





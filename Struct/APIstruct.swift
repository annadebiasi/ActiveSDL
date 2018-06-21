//
//  APIstruct.swift
//  Events Center
//
//  Created by De biasi, Anna (A.) on 6/12/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//


import Foundation

struct APIStruct : Codable {
    // Place
    struct Place: Codable{
        let addressLine1Txt: String
        let stateProvinceCode: String
        let cityName: String
    }
    // Description
    struct AssetDescriptions: Codable{
        let description: String
    }
    // Prices
    struct AssetPrices: Codable{
        let priceAmt: Int
    }
    // Organization
    struct Organization: Codable{
        let organizationName: String
        let primaryContactPhone: String
    }
    
    let assetDescriptions: [AssetDescriptions]
    let assetPrices: [AssetPrices]
    let place: Place
    let organization: Organization
    let salesStartDate: String
    let salesEndDate: String
    
    init?(withData soccerData: [String: Any])
    {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: soccerData) else { return nil }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
        guard let soccerData = jsonString.data(using: .utf8) else { return nil }
        guard let condition = try? JSONDecoder().decode(APIStruct.self, from: soccerData) else { return nil }
        self = condition
    }
}

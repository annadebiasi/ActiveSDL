//
//  utils.swift
//  Events Center
//
//  Created by De biasi, Anna (A.) on 6/15/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import Foundation
import MapKit

// retrieves and parses json data into an array
func getJson(str: String, completion: @escaping ([APIStruct]) ->()) { //_ callBack: (()-> ())?
   // let access_key = "8auynm8hk7ejhq84pr64v77u"
    var apiStructData  = [APIStruct]()
    let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
    let url = URL(string: "http://api.amp.active.com/v2/search?query=\(str.lowercased())&category=event&start_date=2017-10-04..&near=Palo%20Alto,CA,US&radius=200&api_key=8auynm8hk7ejhq84pr64v77u")!
    let task = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        guard let data = data else {
            return
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return
        }
        let dictJson = json as! [String : Any]
        var organizationNames = [String]()
        for (key,_) in dictJson{
            if(key == "results"){
                for result in dictJson["results"] as! [[String:Any]]{
                    let apiStruct = APIStruct(withData: result)
                    if(!organizationNames.contains(apiStruct!.organization.organizationName)){
                    apiStructData.append(apiStruct!)
                        organizationNames.append((apiStruct?.organization.organizationName)!)
                    }
                }
            }
        }
        completion(apiStructData)
    })
    task.resume()
}

// formats date
func getProperDate(from date: String) -> String? {
    // date format is YYYY-MM-DD
    let value = date
    let date1 = value[..<value.index(value.startIndex, offsetBy: 10)]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-mm-dd"
    guard let date = dateFormatter.date(from: String(date1)) else { return nil }
    dateFormatter.dateFormat = "MMMM dd, YYYY"
    let properDate = dateFormatter.string(from: date)
    return properDate
}

// gets specific integer from event
func switchMenu(str: String) -> Int {
    var num = 0
    switch str{
    case "nutrition":
        num = 1
    case "soccer":
        num = 2
    case "golf":
        num = 3
    default:
        num = 0
    }
    return(num)
}




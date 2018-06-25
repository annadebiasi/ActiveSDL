//
//  ViewController.swift
//  TestSDL
//
//  Created by De biasi, Anna (A.) on 6/8/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // initializes variables
    var apiStructData = [APIStruct]()
    var str : String?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProxyManager.sharedManager.clickedEventDelegate = self
        spinner.startAnimating()
        // retrieving json data
        getJson(str: self.str!){ jsonData in
                    self.apiStructData = jsonData
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                    self.table.reloadData()
                    let num = switchMenu(str: String(describing: self.str!))
                    ProxyManager.sharedManager.makeCustomMenu(activity: String(describing: self.str!), num: num, jsonData: self.apiStructData)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiStructData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell0")
        let key = (apiStructData[indexPath.row]).organization.organizationName
        let value = (apiStructData[indexPath.row]).salesEndDate
        var str = String(value)
        str = (getProperDate(from: str))!
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(key): \(str)"
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "labeling", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if the phone button is pressed
        if let indexPath = sender as? IndexPath{
            if (segue.identifier == "labeling"){
                let Labeling =  segue.destination as! Labeling
                Labeling.apiStruct = apiStructData[indexPath.row]
                Labeling.str = str
                ProxyManager.sharedManager.createAlert(activity: (str!), jsonData: apiStructData, identifier : indexPath.row)
            }
        // if the TDK button is pressed
        } else if let num = sender as? Int{
            if (segue.identifier == "labeling"){
                let Labeling = segue.destination as! Labeling
                Labeling.apiStruct = apiStructData[num]
                Labeling.str = str
            }
        }
    }
}







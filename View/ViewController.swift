//
//  ViewController.swift
//  TestSDL
//
//  Created by De biasi, Anna (A.) on 6/8/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit

protocol ChoseEventDelegate: class {
    func didGoBack()
    func choseEventPhone(activity: String, jsonData:[APIStruct] , identifier : Int)
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var choseEventDelegate : ChoseEventDelegate!
    
    var apiStructData = [APIStruct]()
    
    var str : String?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        getJson(str: self.str!){ jsonData in
                    self.apiStructData = jsonData
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                    self.table.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiStructData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell0")
        let key   = (apiStructData[indexPath.row]).organization.organizationName
        let value = (apiStructData[indexPath.row]).salesEndDate
        var str = String(value)
        str = (getProperDate(from: str))!
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(key): \(str)"
        return(cell)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        super.viewWillDisappear(animated)
        // The back button was pressed or interactive gesture used
        ProxyManager.sharedManager.didGoBack()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "labeling", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath{
            print("INDEX PATH SEGUE  ", apiStructData.count, " ", (str?.lowercased())!, " ", indexPath.row)
            if (segue.identifier == "labeling"){
                let Labeling =  segue.destination as! Labeling
                Labeling.apiStruct = apiStructData[indexPath.row]
                choseEventDelegate = ProxyManager.sharedManager
                self.choseEventDelegate.choseEventPhone(activity: (str!), jsonData: apiStructData, identifier : indexPath.row)
            }
        } else if let num = sender as? Int{
            print("INT SEGUE")
            if (segue.identifier == "labeling"){
                let Labeling = segue.destination as! Labeling
                Labeling.apiStruct = apiStructData[num]
            }
        }
    }
}






//
//  MainViewController.swift
//  Events Center
//
//  Created by De biasi, Anna (A.) on 6/15/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit

class MainViewController: UIViewController{
    
    override func viewDidLoad(){
        super.viewDidLoad()
        ProxyManager.sharedManager.clickedSportDelegate = self
    }
    
// Segues into the ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.destination is ViewController){
            let vc = segue.destination as? ViewController
            vc?.str = "\(String(describing: segue.identifier!))"
        }
    }
}







//
//  MainViewController.swift
//  Events Center
//
//  Created by De biasi, Anna (A.) on 6/15/18.
//  Copyright © 2018 De biasi, Anna (A.). All rights reserved.
//

import UIKit

protocol ChoseSportDelegate: class {
    func didRequestMenuItems(event : String)
}

class MainViewController: UIViewController {
    var choseSportDelegate = ProxyManager.sharedManager as ChoseSportDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        ProxyManager.sharedManager.clickedSportDelegate = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.destination is ViewController){
            let vc = segue.destination as? ViewController
            vc?.str = "\(String(describing: segue.identifier!))"
            if sender is Int{
                print("sender is an integer ")
            }else{
                print("sender is not an integer")
                self.choseSportDelegate.didRequestMenuItems(event: String(describing: segue.identifier!))
            }
        }
    }
}







//
//  SecondViewController.swift
//  SorryApp
//
//  Created by Arvindram Krishnamoorthy on 7/19/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit
extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: self.borderColor!)
        }
    }
}

class SecondViewController: UIViewController {
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // pull timesSaidSorry and not sorry from database
        // Reset to zero once a day has past
        NSLog("nsuserdefault email \(delegate.defaults.stringForKey("email")!)")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var timesSaidSorry: UILabel!
    @IBOutlet weak var timesNoSorry: UILabel!
    
    @IBAction func saidSorry(sender: AnyObject) {
        let sorryCount = 0; // pull from database
        updateSorryCount(sorryCount)
        
    }

    @IBAction func didnotSaySorry(sender: AnyObject) {
        let noCount = 0; // pull from database
        updateSorryCount(noCount)
    }
    
    func updateSorryCount(counts : Int){
        //update it on the screen
        
        //get the timestamp
        
        //update database with new sorry/not sorry count and timestamp
    }
}


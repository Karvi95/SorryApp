//
//  BaseTabBarController.swift
//  SorryApp
//
//  Created by Arvindram Krishnamoorthy on 9/19/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

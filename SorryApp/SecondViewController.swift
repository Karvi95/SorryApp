//
//  SecondViewController.swift
//  SorryApp
//
//  Created by Arvindram Krishnamoorthy on 7/19/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyJSON

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
    let userEnpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/users.php"
    let sNSEndpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/sorrynotsorry.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientView = GradientView(frame: self.view.bounds);
        self.view.insertSubview(gradientView, atIndex: 0);
        
        // pull timesSaidSorry and not sorry from database
        // Reset to zero once a day has past
        NSLog("nsuserdefault email \(delegate.defaults.stringForKey("email")!)")
        updateSNSCount("sorry")
        updateSNSCount("notsorry")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var timesSaidSorry: UILabel!
    
    @IBOutlet weak var timesNoSorry: UILabel!
    
    @IBAction func saidSorry(sender: AnyObject) {
        timesSaidSorry.text = String(Int(timesSaidSorry.text!)! + 1)
        saidSNS("sorry")
    }

    @IBAction func noSorry(sender: AnyObject) {
        timesNoSorry.text = String(Int(timesNoSorry.text!)! + 1)
        saidSNS("notsorry")
    }
    
    
    func updateSorryCount(counts : Int){
        //update it on the screen
        
        //get the timestamp
        
        //update database with new sorry/not sorry count and timestamp
    }
    
    func updateSNSCount(sorrynotsorry: String){
        let access_token = self.delegate.defaults.stringForKey("access_token")!
        let params = "?email=" + delegate.defaults.stringForKey("email")! + "&sorrynotsorry=" + sorrynotsorry + "&access_token=" + access_token
        let request = NSMutableURLRequest(URL: NSURL(string: sNSEndpoint + params)!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, er in
            
            if er != nil{
                NSLog("get sns error: \(sorrynotsorry)")
                return
            }
            
            var response_status = Int()
            if let httpResponse = response as? NSHTTPURLResponse {
                response_status = httpResponse.statusCode
            }
            if(response_status != 200){
                if(response_status == 403){
                    self.logout()
                    return
                }
                NSLog("cannot access endpoint, error code \(response_status)")
                return
            }
            let swiftyJSON = JSON(data: data!)
            let status = swiftyJSON["status"].stringValue
            if status == "200"{
                let numSNS = swiftyJSON["data"]["num_" + sorrynotsorry][0].stringValue
                NSLog(numSNS)
                dispatch_async(dispatch_get_main_queue()){
                    if sorrynotsorry=="sorry"{
                        self.timesSaidSorry.text = numSNS
                    }
                    else{
                        self.timesNoSorry.text = numSNS
                    }
                }
            }
        }
        task.resume()
            
    }
    
    func saidSNS(sorrynotsorry: String){
        let request = NSMutableURLRequest(URL: NSURL(string: sNSEndpoint)!)
        request.HTTPMethod = "POST"
        let postString = "email=" + delegate.defaults.stringForKey("email")! + "&sorrynotsorry=" + sorrynotsorry
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, er in
            
            if er != nil{
                NSLog("error")
                return
            }
            var response_status = Int()
            if let httpResponse = response as? NSHTTPURLResponse {
                response_status = httpResponse.statusCode
            }
            if response_status != 200 {
                NSLog("cannot access endpoint, error code \(response_status)")
                return
            }
            let swiftyJSON = JSON(data: data!)
            let status = swiftyJSON["status"].stringValue
            if(status == "200"){
                self.updateSNSCount(sorrynotsorry)
            }
            else{
                NSLog("error code " + status)
            }
        }
        
        task.resume()
        
    }
    func logout(){
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
}
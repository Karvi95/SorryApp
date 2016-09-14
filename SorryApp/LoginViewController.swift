//
//  LoginViewController.swift
//  SorryApp
//
//  Created by Joshua Hall on 7/25/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyJSON

class LoginViewController: UIViewController {
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var details: UILabel!
    
    let loginButton : FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loginButton)
        loginButton.center = view.center
        // Do any additional setup after loading the view, typically from a nib.
        let token = FBSDKAccessToken.currentAccessToken()
        if (token != nil) {
            fetchProfile()
        }
        
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result : FBSDKLoginManagerLoginResult){
        fetchProfile()
    }
    
    func fetchProfile(){
        let parameters = ["fields": "email, first_name, last_name, link, picture, gender"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler { (connection, result, error) -> Void in
        
            if (error == nil) {
                let endpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/users.php"
                var email = result["email"] as! String
                var params = "?email=" + email
                let get = NSMutableURLRequest(URL: NSURL(string: endpoint + params)!)
                get.HTTPMethod = "GET"
                let gettask = NSURLSession.sharedSession().dataTaskWithRequest(get){
                    data, response, er in
                    
                    if er != nil{
                        NSLog("geterror")
                        return
                    }
                    
                    NSLog("response: \(response!)")
                    var response_status = Int()
                    if let httpResponse = response as? NSHTTPURLResponse {
                        response_status = httpResponse.statusCode
                    }
                    if(response_status != 200){
                        NSLog("cannot access endpoint, error code \(response_status)")
                        return;
                    }
                    let swiftyJSON = JSON(data: data!)
                    var status = swiftyJSON["status"].stringValue
                    var userEmail = swiftyJSON["data"]["user"][0]["Email"].stringValue
                    NSLog("status: \(status) email: \(userEmail)")
                    
                    if status == "200" {
                        NSLog("found")
                        self.delegate.defaults.setObject(email, forKey: "email")
                        //let meVC = self.storyboard?.instantiateViewControllerWithIdentifier("Me") as! SecondViewController
                        //self.presentViewController(meVC, animated: false, completion: nil)
                        self.performSegueWithIdentifier("login", sender: self)
                        }
                    else{
                        NSLog("User Not found!");
                        let url = NSURL(string: endpoint)
                        let request = NSMutableURLRequest(URL: url!)
                        request.HTTPMethod = "POST"
                        let fname = result["first_name"] as! String
                        let lname = result["last_name"] as! String
                        let dob = "1994-12-19"//result["birthday"] as! String
                        let gender = result["gender"] as! String
                        var postString = "email=" + email
                        postString += "&first_name=" + fname
                        postString += "&last_name=" + lname
                        postString += "&dob=" + dob
                        postString += "&gender=" + gender
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
                            data, response, er in
                            
                            if er != nil{
                                NSLog("error")
                                return
                            }
                            response_status = Int()
                            if let httpResponse = response as? NSHTTPURLResponse {
                                response_status = httpResponse.statusCode
                            }
                            if(response_status != 200){
                                NSLog("cannot access endpoint, error code \(response_status)")
                                return
                            }
                            
                            NSLog("postString: \(postString) response: \(response)")
                            let swiftyJSON = JSON(data: data!)
                            var status = swiftyJSON["status"].stringValue
                            if(status == "200"){
                                NSLog("user addded")
                                self.delegate.defaults.setObject(email, forKey: "email")
                                let meVC = self.storyboard?.instantiateViewControllerWithIdentifier("Me") as! SecondViewController
                                self.presentViewController(meVC, animated: false, completion: nil)
                            }
                            else{
                                NSLog("error code " + status)
                            }

                            
                        }
                        task.resume()

                    }

                }
                gettask.resume()
                

         //       let secondVC:SecondViewController = SecondViewController()
          //      self.presentViewController(secondVC, animated: true, completion: nil)
            }
//            if let link = result["link"] as? String {
//                NSLog(link)
//            }
//            if let email = result["email"] as? String {
//                NSLog(email)
//            }
//            if let fname = result["first_name"] as? String {
//                NSLog(fname)
//            }
//            if let lname = result["last_name"] as? String {
//                NSLog(lname)
//            }
//            if let pic = result["picture"] as? String {
//                NSLog(pic)
//            }
//            if(error != nil){
//                print(error)
//            }
        }
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

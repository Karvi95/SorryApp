//
//  LoginViewController.swift
//  SorryApp
//
//  Created by Joshua Hall on 7/25/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
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
                let url = NSURL(string: "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/users.php")
                let request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "POST"
                var email = result["email"] as! String
                var fname = result["first_name"] as! String
                var lname = result["last_name"] as! String
                var dob = "1994-12-19"//result["birthday"] as! String
                var gender = result["gender"] as! String
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
                    
                    NSLog("postString: \(postString) response: \(response)")
                }
                task.resume()
                let meVC = self.storyboard?.instantiateViewControllerWithIdentifier("Me") as! SecondViewController
                self.presentViewController(meVC, animated: false, completion: nil)
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

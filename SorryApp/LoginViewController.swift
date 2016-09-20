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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var details: UILabel!
    let endpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/users.php"
    
    let loginButton : FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let background = CAGradientLayer().turquoiseColor();
        background.frame = self.view.bounds;
        self.view.layer.insertSublayer(background, atIndex: 0);
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        let token = FBSDKAccessToken.currentAccessToken()
        if (token != nil) {
            self.delegate.defaults.setObject(token.tokenString, forKey: "access_token")
            fetchProfile()
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        view.addSubview(loginButton)
        loginButton.center = view.center
        loginButton.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        fetchProfile()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true;
    }
    
    func fetchProfile(){
        let parameters = ["fields": "email, first_name, last_name, link, picture, gender"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler { (connection, result, error) -> Void in

            if (error == nil) {
                let email = result["email"] as! String
                NSLog(email)
                let access_token = self.delegate.defaults.stringForKey("access_token")!
                let params = "?email=" + email + "&access_token=" + access_token
                let get = NSMutableURLRequest(URL: NSURL(string: self.endpoint + params)!)
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
                        if(response_status == 404){
                            NSLog("User not found")
                            self.createUser(result, email: email)
                            return
                        }
                        let swiftyJSON = JSON(data: data!)
                        NSLog("cannot access endpoint, error code \(response_status) \(swiftyJSON["status_message"])")
                        return
                    }
                    let swiftyJSON = JSON(data: data!)
                    let status = swiftyJSON["status"].stringValue
                    let userEmail = swiftyJSON["data"]["user"][0]["Email"].stringValue
                    NSLog("status: \(status) email: \(userEmail)")
                    
                    if status == "200" {
                        NSLog("found")
                        self.delegate.defaults.setObject(email, forKey: "email")
                        //let meVC = self.storyboard?.instantiateViewControllerWithIdentifier("Me") as! SecondViewController
                        //self.presentViewController(meVC, animated: false, completion: nil)
                        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
                        dispatch_after(delay, dispatch_get_main_queue()){
                            self.performSegueWithIdentifier("login", sender: self)
                            }
                        }
                    else{
                        NSLog("User Not found!")
                        self.createUser(result, email: email)
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
    
    
    
    func createUser(result : AnyObject, email: String){
        let access_token = self.delegate.defaults.stringForKey("access_token")!
        let params = "?access_token=" + access_token
        let url = NSURL(string: endpoint + params)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let fname = result["first_name"] as! String
        let lname = result["last_name"] as! String
        let gender = result["gender"] as! String
        var postString = "email=" + email
        postString += "&first_name=" + fname
        postString += "&last_name=" + lname
        postString += "&gender=" + gender
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
            if(response_status != 200){
                if(response_status == 403){
                    self.logout()
                    return
                }
                NSLog("cannot access endpoint, error code \(response_status) \(postString)")
                return
            }
            
            NSLog("postString: \(postString) response: \(response)")
            _ = JSON(data: data!)
            NSLog("user addded")
            self.delegate.defaults.setObject(email, forKey: "email")
            let meVC = self.storyboard?.instantiateViewControllerWithIdentifier("Me") as! SecondViewController
            self.presentViewController(meVC, animated: false, completion: nil)
        }
        task.resume()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logout(){
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)

    }
}

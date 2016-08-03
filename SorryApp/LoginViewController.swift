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
        
        if let token = FBSDKAccessToken.currentAccessToken() {
            fetchProfile()
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result : FBSDKLoginManagerLoginResult){
        fetchProfile()
    }
    
    func fetchProfile(){
        let parameters = ["fields": "email, first_name, last_name, link, picture"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler { (connection, result, error) -> Void in
            
            if let link = result["link"] as? String {
                NSLog(link)
            }
            if let email = result["email"] as? String {
                NSLog(email)
            }
            if let fname = result["first_name"] as? String {
                NSLog(fname)
            }
            if let lname = result["last_name"] as? String {
                NSLog(lname)
            }
            if let pic = result["picture"] as? String {
                NSLog(pic)
            }
            if(error != nil){
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        
    }
    
}

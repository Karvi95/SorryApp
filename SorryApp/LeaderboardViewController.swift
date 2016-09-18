//
//  LeaderboardViewController.swift
//  SorryApp
//
//  Created by iGuest on 7/22/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit
import SwiftyJSON

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let endpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/leaderboard.php"
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var names = ["", "", "", "", "", "", "", "", "", ""]
    var counts = ["", "", "", "", "", "", "", "", "", ""]
    @IBOutlet weak var table: UITableView!
    
    private var snsLabels = [UILabel]()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func changeSNS(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex{
            case 0:
                updateLeaderboard("sorry")
                break
            case 1:
                updateLeaderboard("notsorry")
                break
            default:
                break
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientView = GradientView(frame: self.view.bounds);
        self.view.insertSubview(gradientView, atIndex: 0);
        
        updateLeaderboard("sorry")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = self.table.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        
            cell.rank.text = String(indexPath.row + 1) + "."
            cell.user.text = names[indexPath.row]
            cell.sns.text = counts[indexPath.row]
        
        return cell
        
    }
    
    func updateLeaderboard(sorrynotsorry: String){
        self.names = ["", "", "", "", "", "", "", "", "", ""]
        self.counts = ["", "", "", "", "", "", "", "", "", ""]
        let params = "?sorrynotsorry=" + sorrynotsorry
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint + params)!)
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
                NSLog("cannot access endpoint, error code \(response_status)")
                return
            }
            let swiftyJSON = JSON(data: data!)
            let status = swiftyJSON["status"].stringValue
            if status == "200"{
                let users = swiftyJSON["data"]["user"]
                var i = 0
                for user in users{
                    self.names[i] = user.1["FirstName"].stringValue + " " + user.1["LastName"].stringValue
                    self.counts[i] = user.1["Score"].stringValue
                    i += 1
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.table.reloadData()
                }
            }
            else{
                NSLog("Error code " + status)
            }
        }
        task.resume()
        
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

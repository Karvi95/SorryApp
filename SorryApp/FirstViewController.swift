//
//  FirstViewController.swift
//  SorryApp
//
//  Created by Arvindram Krishnamoorthy on 7/19/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit

import Charts
import SwiftyJSON

class FirstViewController: UIViewController {
    @IBOutlet weak var chart: LineChartView!
    let userEnpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/users.php"
    let sNSEndpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/sorrynotsorry.php"

    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var x = [String]()
    var y = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChart("week")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loadChart(type: String){
        x.removeAll()
        y.removeAll()
        let params = "?email=" + delegate.defaults.stringForKey("email")! + "&sorrynotsorry=sorry" + "&type=" + type
        let request = NSMutableURLRequest(URL: NSURL(string: sNSEndpoint + params)!)
        request.HTTPMethod = "GET"
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
                NSLog("cannot access endpoint, error code \(response_status)")
                return
            }
            let swiftyJSON = JSON(data: data!)
            var status = swiftyJSON["status"].stringValue
            if status == "200"{
                let records = swiftyJSON["data"]["records"]
                var i = 0
                for record in records{
                    self.x.append(record.1["Date"].stringValue)
                    self.y.append(Double(record.1["SCORE"].stringValue)!)
                    i += 1
                }
                var dataEntries: [ChartDataEntry] = []
                i = 0
                for date in self.x{
                    let dataEntry = ChartDataEntry(value: self.y[i], xIndex: i)
                    dataEntries.append(dataEntry)
                    i += 1
                }
                let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label:"sorry")
                lineChartDataSet.circleColors = [NSUIColor.blueColor()]
                var dataSets : [LineChartDataSet] = [LineChartDataSet]()
                dataSets.append(lineChartDataSet)
                let lineChartData = LineChartData(xVals: self.x, dataSets: dataSets)
                self.chart.data = lineChartData
            }
            else{
                NSLog("error code " + status)
            }
        }
        task.resume()

    }

}


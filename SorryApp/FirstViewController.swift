//
//  FirstViewController.swift
//  SorryApp
//
//  Created by Arvindram Krishnamoorthy on 7/19/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit

import Charts
import FBSDKLoginKit
import SwiftyJSON

class FirstViewController: UIViewController {
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var snsSegmentControl: UISegmentedControl!
    let userEnpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/users.php"
    let sNSEndpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/sorrynotsorry.php"

    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var x = [String]()
    var y = [Double]()
    var yearDict: [String:String] = [
        "1" : "Jan",
        "2" : "Feb",
        "3" : "Mar",
        "4" : "Apr",
        "5" : "May",
        "6" : "Jun",
        "7" : "Jul",
        "8" : "Aug",
        "9" : "Sep",
        "10" : "Oct",
        "11" : "Nov",
        "12" : "Dec"];
    var typeG = "week"
    var sorrynotsorryG = "sorry"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientView = GradientView(frame: self.view.bounds);
        self.view.insertSubview(gradientView, atIndex: 0);
        
        loadChart()
    }

    @IBAction func changeSNS(sender: AnyObject) {
        switch(snsSegmentControl.selectedSegmentIndex){
            case 0:
                sorrynotsorryG = "sorry"
                loadChart()
                break
            case 1:
                sorrynotsorryG = "notsorry"
                loadChart()
                break
            default:
                break
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func timePeriodSegmentControl(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            typeG = "week"
            loadChart();
        case 1:
            typeG = "month"
            loadChart();
        case 2:
            typeG = "year"
            loadChart();
        default:
            break; 
        }
    }

    
    func loadChart(){
        x.removeAll()
        y.removeAll()
        getData(sorrynotsorryG, type: typeG)
    }
    
    func getData(sorrynotsorry: String, type: String){
        let dateString = delegate.getCurrentDateTime()
        let access_token = self.delegate.defaults.stringForKey("access_token")!
        let params = "?email=" + delegate.defaults.stringForKey("email")! + "&sorrynotsorry=" + sorrynotsorry + "&type=" + type + "&timestamp=" + dateString + "&access_token=" + access_token
        let request = NSMutableURLRequest(URL: NSURL(string: sNSEndpoint + params)!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
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
                NSLog("cannot access endpoint, error code \(response_status)")
                return
            }
            let swiftyJSON = JSON(data: data!)
            let status = swiftyJSON["status"].stringValue
            if status == "200"{
                let records = swiftyJSON["data"]["records"]
                var i = 0
                for record in records{
                    var myDate = record.1["Date"].stringValue;
                    if (self.typeG == "year") {
                        myDate = self.yearDict[myDate]!;
                    }
                    if (self.typeG == "week" || self.typeG == "month") {
                        let indexStartOfTextMonth = myDate.startIndex.advancedBy(5)
                        let indexEndOfTextMonth = myDate.endIndex.advancedBy(-3)
                    
                        let resultStringMonth = myDate.substringWithRange(indexStartOfTextMonth..<indexEndOfTextMonth)

                        let indexStartOfTextDay = myDate.startIndex.advancedBy(8)
                        let indexEndOfTextDay = myDate.endIndex.advancedBy(0)
                     
                        let resultStringDay = myDate.substringWithRange(indexStartOfTextDay..<indexEndOfTextDay)
                        
                        
                        var ending = "th of "
                        if (resultStringDay == "01") {
                            ending = "st of "
                        }
                        if (resultStringDay == "02") {
                            ending = "nd of "
                        }
                        if (resultStringDay == "03") {
                            ending = "rd of "
                        }
                        
                        let resultString = resultStringDay + ending + resultStringMonth
                        
                        print("NEW DATE: " + resultString)
                        
                        myDate = resultString
                        
                    }
                    self.x.append(myDate);
                    self.y.append(Double(record.1["SCORE"].stringValue)!)
                    i += 1
                }
                var dataEntries: [ChartDataEntry] = []
                i = 0
                for _ in self.x {
                    let dataEntry = ChartDataEntry(value: self.y[i], xIndex: i)
                    dataEntries.append(dataEntry)
                    i += 1
                }
                dispatch_async(dispatch_get_main_queue()){
                    var lineChartSorryDataSet : LineChartDataSet;
                    if (self.sorrynotsorryG == "sorry") {
                        lineChartSorryDataSet = LineChartDataSet(yVals: dataEntries, label:"Sorry")
                        lineChartSorryDataSet.colors = [NSUIColor.redColor()];
                    } else {
                        lineChartSorryDataSet = LineChartDataSet(yVals: dataEntries, label:"Not sorry")
                        lineChartSorryDataSet.colors = [NSUIColor.blueColor()];
                    }
                    
                    lineChartSorryDataSet.drawCirclesEnabled = false;
                    
                    var dataSets : [LineChartDataSet] = [LineChartDataSet]()
                    dataSets.append(lineChartSorryDataSet)
                    let lineChartData = LineChartData(xVals: self.x, dataSets: dataSets)
                    
                    let yAxisRight = self.chart.getAxis(ChartYAxis.AxisDependency.Right);
                    yAxisRight.drawLabelsEnabled = false;
                    let yAxisLeft = self.chart.getAxis(ChartYAxis.AxisDependency.Left);
                    yAxisLeft.axisMinValue = 0;
                    var paddingUp = 0;
                    let potentialMax = Int(self.y.maxElement()!);
                    if (potentialMax >= 20) {
                        paddingUp = 5;
                    }
                    if (potentialMax >= 100) {
                        paddingUp = potentialMax / 2;
                    }
                    if (potentialMax >= 1000) {
                        paddingUp = potentialMax / 4;
                    }
                    yAxisLeft.axisMaxValue = Double(Int((Double(potentialMax) + Double(paddingUp))));
                    
                    yAxisRight.drawGridLinesEnabled = false;
                    yAxisLeft.drawGridLinesEnabled = false;
                    
                    yAxisLeft.valueFormatter = NSNumberFormatter()
                    yAxisLeft.valueFormatter!.minimumFractionDigits = 0
                    
                    self.chart.multipleTouchEnabled = false;
                    self.chart.doubleTapToZoomEnabled = false;
                    
                    self.chart.xAxis.labelPosition = .Bottom
                    
                    self.chart.data = lineChartData
                }
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


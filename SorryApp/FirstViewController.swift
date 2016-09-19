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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let userEnpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/users.php"
    let sNSEndpoint = "http://sorryapp.canadacentral.cloudapp.azure.com/SorryAppBackend/sorrynotsorry.php"

    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var x = [String]();
    var y = [Double]();
    var typeG = "week"
    var sorrynotsorryG = "sorry"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientView = GradientView(frame: self.view.bounds);
        self.view.insertSubview(gradientView, atIndex: 0);
        
        loadChart()
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
        let params = "?email=" + delegate.defaults.stringForKey("email")! + "&sorrynotsorry=" + sorrynotsorry + "&type=" + type
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
                NSLog("cannot access endpoint, error code \(response_status)")
                return
            }
            let swiftyJSON = JSON(data: data!)
            let status = swiftyJSON["status"].stringValue
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
                for _ in self.x {
                    let dataEntry = ChartDataEntry(value: self.y[i], xIndex: i)
                    dataEntries.append(dataEntry)
                    i += 1
                }
                dispatch_async(dispatch_get_main_queue()){
                    let lineChartSorryDataSet = LineChartDataSet(yVals: dataEntries, label:"sorry")
                    lineChartSorryDataSet.circleColors = [NSUIColor.blueColor()]
                    var dataSets : [LineChartDataSet] = [LineChartDataSet]()
                    dataSets.append(lineChartSorryDataSet)
                    let lineChartData = LineChartData(xVals: self.x, dataSets: dataSets)
                    
                    let yAxisRight = self.chart.getAxis(ChartYAxis.AxisDependency.Right);
                    yAxisRight.drawLabelsEnabled = false;
                    let yAxisLeft = self.chart.getAxis(ChartYAxis.AxisDependency.Left);
                    yAxisLeft.axisMinValue = 0;
                    yAxisLeft.axisMaxValue = self.y.maxElement()! + 5;
                    
                    yAxisRight.drawGridLinesEnabled = false;
                    yAxisLeft.drawGridLinesEnabled = false;
                    
                    yAxisLeft.valueFormatter = NSNumberFormatter()
                    yAxisLeft.valueFormatter!.minimumFractionDigits = 0
                    
                    self.chart.data = lineChartData
                }
            }
            else{
                NSLog("error code " + status)
            }
        }
        task.resume()
    }

}


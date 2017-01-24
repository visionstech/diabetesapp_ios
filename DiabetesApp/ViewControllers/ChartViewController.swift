//
//  ChartViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 30/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire

class ChartViewController: UIViewController, LineChartDelegate {

    @IBOutlet weak var glucoseLbl: UILabel!
    @IBOutlet weak var deviationLbl: UILabel!
    @IBOutlet weak var hyposLbl: UILabel!
    @IBOutlet weak var hyperLbl: UILabel!
    @IBOutlet weak var hbaLbl: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var readingsView: UIView!
    
    var label = UILabel()
    var lineChart: LineChart!
    var noOfDays = "1"
    
//    let chartConditionsArray : NSArray = ["Fasting", "Snacks", "Exercise","Pre Breakfast", "Post Breakfast", "Pre Lunch", "Post Lunch", "Pre Dinner", "Post Dinner", "Bedtime"]
    let chartConditionsArray : NSArray = ["F", "S", "E","PrB", "PoB", "PrL", "PoL", "PrD", "PoD", "B"]
    var dataArray: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUI()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.chartHistoryView), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetUI(){
        if self.dataArray.count > 0 {
            self.chartView.isHidden = false
            self.readingsView.isHidden = false
            self.drawChart()
        }
        else {
            self.chartView.isHidden = true
            self.readingsView.isHidden = true
        }
    }
    
    // MARK: - Api Methods
    func getChartHistoryData(condition: String) {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
        dataArray.removeAllObjects()
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
             "userid": patientsID,
            "numDaysBack": noOfDays,
            "condition": condition
        ]
        
        print(parameters)
        
        Alamofire.request("http://54.244.176.114:3000/\(ApiMethods.getglucoseDaysConditionChart)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                    if mainArray.count > 0 {
                        for dict in mainArray {
                            let mainDict: NSDictionary = dict as! NSDictionary
                            if (mainDict.allKeys.first != nil)  {
                                let dateStr: String = String(describing: mainDict.allKeys.first!)
                                let readingsArray: NSArray = mainDict.object(forKey: dateStr) as! NSArray
                                // var data: Array = [CGFloat]
                                var data: [CGFloat] = []
                                for i in 0..<self.chartConditionsArray.count {
                                    data.append(0)
                                    for dict in readingsArray {
                                        let ob: NSDictionary = dict as! NSDictionary
                                        let conditionIndex: Int = ob.value(forKey: "conditionIndex")! as! Int
                                        if i == conditionIndex {
                                            data[i] = ob.value(forKey: "reading")! as! CGFloat
                                            break
                                        }
                                    }
                                }
                                self.dataArray.add(data)
                            }
                        }
                        
                        print("data \(self.dataArray)")
                        self.resetUI()
                    }
                    
                }
                
                break
            case .failure:
                print("failure")
                self.resetUI()
                break
                
            }
         }
        }
    }
    
    
    //MARK: - Notifications Methods
    func chartViewNotification(notification: NSNotification) {
        getChartHistoryData(condition: conditionsArray[0] as! String)
       // self.drawChart()
    }
    
    func noOfDaysNotification(notification: NSNotification) {
        
        noOfDays = String(describing: notification.value(forKey: "object")!)
        print("noOfDays \(noOfDays)")
        getChartHistoryData(condition: conditionsArray[0] as! String)
        
    }
    
    //MARK: - Custom Methods
    func setUI(){
        glucoseLbl.layer.cornerRadius = 5
        deviationLbl.layer.cornerRadius = 5
        hyposLbl.layer.cornerRadius = 5
        hyperLbl.layer.cornerRadius = 5
        hbaLbl.layer.cornerRadius = 5
        
        glucoseLbl.layer.masksToBounds = true
        deviationLbl.layer.masksToBounds = true
        hyposLbl.layer.masksToBounds = true
        hyperLbl.layer.masksToBounds = true
        hbaLbl.layer.masksToBounds = true
        
        addNotifications()
    }
    
    func addNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.chartViewNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.chartHistoryView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.noOfDaysNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
    }
    
    
    func drawChart(){
        
        if lineChart != nil {
            self.lineChart.clearAll()
            self.lineChart.removeFromSuperview()
        }
        
        var views: [String: AnyObject] = [:]
        
        label.text = "November 2016"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textColor = Colors.outgoingMsgColor
       // chartView.addSubview(label)
        //views["label"] = label
        //chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
        //chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[label]", options: [], metrics: nil, views: views))
        
        // simple line with custom x axis labels
        
        let xLabels: [String] = chartConditionsArray as! [String]
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
       
        for data in dataArray {
            
            let dataAr: [CGFloat] = data as! Array
            lineChart.addLine(dataAr)
            
        }
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        chartView.addSubview(lineChart)
        
        views["chart"] = lineChart
      
        chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
        chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[chart]-|", options: [], metrics: nil, views: views))
       // chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
        
    }
    
    /**
     * Line chart delegate method.
     */
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        print("x \(x) yValues \(yValues)")
        //label.text = "x: \(x)     y: \(yValues)"
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
import SwiftCharts
import Darwin


private enum MyExampleModelDataType {
    case type0, type1, type2, type3, type4, type5
}

private enum Shape {
    case triangle, square, circle, cross
}
class ChartViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    fileprivate var chart: Chart?
//    @IBOutlet weak var glucoseLbl: UILabel!
//    @IBOutlet weak var deviationLbl: UILabel!
    @IBOutlet weak var hyposLbl: UILabel!
    @IBOutlet weak var hyperLbl: UILabel!
   
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var readingsView: UIView!
    
    @IBOutlet weak var IQRLabel: UILabel!
   
    @IBOutlet weak var noHistoryAvailableLabel: UILabel!
    @IBOutlet weak var standardDeviationView: UIView!
    @IBOutlet weak var glucoseView: UIView!

    
    @IBOutlet weak var conditionView: UIView!
    @IBOutlet weak var conditionTxtFld: UITextField!
    @IBOutlet weak var conditionTitle: UILabel!
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet var pickerViewInner: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var formInterval: GTInterval!
    var label = UILabel()
    var noOfDays = "0"
    var selectedConditionIndex : Int = 0
    
    @IBOutlet weak var pickerDoneButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    //    let chartConditionsArray : NSArray = ["Fasting", "Snacks", "Exercise","Pre Breakfast", "Post Breakfast", "Pre Lunch", "Post Lunch", "Pre Dinner", "Post Dinner", "Bedtime"]
    let chartConditionsArray : NSArray = ["","F", "PoB", "PrL", "PoL", "PrD", "PoD", "B"]
    let lowerRangeArray : [CGFloat] = [80.0,80.0,80.0,80.0,80.0,80.0,80.0]
    let higherRangeArray : [CGFloat] = [180.0,180.0,180.0,180.0,180.0,180.0,180.0]
    
    @IBOutlet weak var medianLabel: UILabel!
    var dataArray: NSMutableArray = NSMutableArray()
    
    
    //var hba1cValue : CGFloat = 0.0
    //var hba1cDate : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noHistoryAvailableLabel.text = "No Readings Available".localized
        pickerCancelButton.setTitle("Cancel".localized, for: .normal)
        pickerDoneButton.setTitle("Done".localized, for: .normal)

        selectedConditionIndex = 0
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // selectedConditionIndex = 0

         GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kChartViewScreenName)
        
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
    
    func resetUICondition(dateArray: NSArray){
        if self.dataArray.count > 0 {
            self.chartView.isHidden = false
            self.readingsView.isHidden = false
            self.drawChartCondition(dateArray: dateArray)
            
            noHistoryAvailableLabel.isHidden = true
        }
        else {
            self.chartView.isHidden = true
            self.readingsView.isHidden = true
            noHistoryAvailableLabel.isHidden = false
        }
    }

    
    func resetUI(){
        if self.dataArray.count > 0 {
            self.chartView.isHidden = false
            self.readingsView.isHidden = false
            noHistoryAvailableLabel.isHidden = true
            self.drawChart()
        }
        else {
            self.chartView.isHidden = true
            self.readingsView.isHidden = true
            noHistoryAvailableLabel.isHidden = false
        }
    }
   
    //MARK: - Private Overlay Function 
    private func showOverlay(overlayView: UIView) {
        overlayView.alpha = 0.0
        overlayView.isHidden = false
        
        UIView.animate(withDuration: 0.15) {
            overlayView.alpha = 1.0
        }
    }
    
    private func hideOverlay(overlayView: UIView) {
        UIView.animate(withDuration: 0.15, animations: {
            overlayView.alpha = 0.0
        }) { _ in
            overlayView.isHidden = true
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func conditionBtn_Clicked(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Chart View", action:"Condition Clicked" , label:"Condition Clicked")

        showOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func cancelBtn_Clicked(_ sender: Any) {
        self.view.endEditing(true)
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Chart View", action:"Condition Cancel Clicked" , label:"Condition Cancel Clicked")
        hideOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func okBtn_Clicked(_ sender: Any) {
        self.view.endEditing(true)
        hideOverlay(overlayView: pickerViewContainer)
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Chart View", action:"Condition Select Clicked" , label:"Condition Select Clicked")
        conditionTxtFld.text = conditionsArray[pickerView.selectedRow(inComponent: 0)] as? String
        selectedConditionIndex = pickerView.selectedRow(inComponent: 0) as Int
        // Api Method
        
        if(conditionTxtFld.text! != "All conditions")
        {
            print("Condition text field")
            
            
            let tempString : [String] = conditionTxtFld.text!.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = conditionTxtFld.text!
            }
            getChartConditionData(condition: newCondition)
        }
        else{
            print("All conditions")
            print(conditionTxtFld.text!)
            getChartHistoryData(condition: conditionTxtFld.text!)

        }
    }
    //MARK: - Chart
    fileprivate func toLayers(_ models: [(x: Double, y: Double, type: MyExampleModelDataType)], layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)], xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect) -> [ChartLayer] {
        
        // group chartpoints by type
        var groupedChartPoints: Dictionary<MyExampleModelDataType, [ChartPoint]> = [:]
        for model in models {
            let chartPoint = ChartPoint(x: ChartAxisValueDouble(model.x), y: ChartAxisValueDouble(model.y))
            if groupedChartPoints[model.type] != nil {
                groupedChartPoints[model.type]!.append(chartPoint)
                
            } else {
                groupedChartPoints[model.type] = [chartPoint]
            }
        }
        
        // create layer for each group
        let dim: CGFloat = 7
        let size = CGSize(width: dim, height: dim)
        let layers: [ChartLayer] = groupedChartPoints.map {(type, chartPoints) in
            let layerSpecification = layerSpecifications[type]!
            switch layerSpecification.shape {
            case .triangle:
                return ChartPointsScatterTrianglesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            case .square:
                return ChartPointsScatterSquaresLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            case .circle:
                return ChartPointsScatterCirclesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            case .cross:
                return ChartPointsScatterCrossesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            }
        }
        
        return layers
    }
    // MARK: - Api Methods
    
    func getChartConditionData(condition: String) {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil
        {
            dataArray.removeAllObjects()
            
            let ConditionVal = conditionsArrayEng[selectedConditionIndex] as? String
            
            let tempString : [String] = ConditionVal!.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = ConditionVal!
            }

           /* let tempString : [String] = condition.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                newCondition = "Pre "+tempString[1]
            }
           else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = condition
            }
            */
            // newCondition = "All conditions"
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let parameters: Parameters = [
                "userid": patientsID,
                "numDaysBack": noOfDays,
                "condition": newCondition
            ]
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            
            Alamofire.request("\(baseUrl)\(ApiMethods.getChartConditionData)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
           
                print("Validation Successful ")
                self.formInterval.end()
               
                switch response.result {
                    
                case .success:
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "getChartConditionData Calling", action:"Success - get Chart Condition Data" , label:"get Chart Condition Data Successfully", value : self.formInterval.intervalAsSeconds())
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        //                    print("JSON")
                        // print(JSON)
                        let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                        let dateArray: NSArray = NSMutableArray(array: JSON.object(forKey: "dateArray") as! NSArray)
                        //self.hba1cValue = JSON.object(forKey: "hba1cValue") as! CGFloat
                        //self.hba1cDate = JSON.object(forKey: "hba1cCreated") as! String
                        
                        
                        if mainArray.count > 0 {
                            for dict in mainArray {
                               // self.noHistoryAvailableLabel.isHidden = true
                                let mainDict: NSDictionary = dict as! NSDictionary
                                if (mainDict.allKeys.first != nil)  {
                                    let dateStr: String = String(describing: mainDict.allKeys.first!)
                                    let readingsArray: NSArray = mainDict.object(forKey: dateStr) as! NSArray
                                    
                                    //  print("Readings Array")
                                    // print(readingsArray)
                                    var data: [CGFloat] = []
                                    for i in 0..<dateArray.count {
                                        data.append(0)
                                        
                                        for dict in readingsArray {
                                            
                                            let ob: NSDictionary = dict as! NSDictionary
                                            let conditionIndex: Int = ob.value(forKey: "dateIndex")! as! Int
                                            
                                            if conditionIndex != -1 && i == conditionIndex {
                                                data[i] = ob.value(forKey: "reading")! as! CGFloat
                                                //commeented the break so that we can select the last value for a given index
                                                //                                            break
                                            }
                                        }
                                        
                                    }
                                    self.dataArray.add(data)
                                }
                            }
                            print("Data Array")
                            print(self.dataArray)
                            self.resetUICondition(dateArray: dateArray)
                            //self.resetUI()
                        }
                        else{
                            self.resetUICondition(dateArray: dateArray)
                            //self.resetUI()
                        }
                        
                    }
                    
                    break
                case .failure(let error):
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "getSpec Calling", action:"Fail - Web API Calling" , label:String(describing: error), value : self.formInterval.intervalAsSeconds())
                    print("failure")
                    self.resetUI()
                    break
                    
                }
            }
        }
    }
    
    
    
    func getChartHistoryData(condition: String) {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil
        {
            dataArray.removeAllObjects()
            var newCondition : String = ""

            /*let tempString : [String] = condition.components(separatedBy: " ")
                        if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = condition
            }*/
            
            newCondition = "All conditions"
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let parameters: Parameters = [
                "userid": patientsID,
                "numDaysBack": noOfDays,
                "condition": newCondition
            ]
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            Alamofire.request("\(baseUrl)\(ApiMethods.getglucoseDaysConditionChart)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            self.formInterval.end()
            switch response.result {
                
            case .success:
                
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysConditionChart) Calling", action:"Success - get Chart History Data" , label:"get Chart History Data Successfully", value : self.formInterval.intervalAsSeconds())
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
//                    print("JSON")
                   // print(JSON)
                    let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                    //self.hba1cValue = JSON.object(forKey: "hba1cValue") as! CGFloat
                    //self.hba1cDate = JSON.object(forKey: "hba1cCreated") as! String
                    
                    
                    if mainArray.count > 0 {
                        for dict in mainArray {
                            self.noHistoryAvailableLabel.isHidden = true
                            let mainDict: NSDictionary = dict as! NSDictionary
                            if (mainDict.allKeys.first != nil)  {
                                let dateStr: String = String(describing: mainDict.allKeys.first!)
                                let readingsArray: NSArray = mainDict.object(forKey: dateStr) as! NSArray
                                var data: [CGFloat] = []
                                for i in 0..<self.chartConditionsArray.count {
                                    data.append(0)
                                    
                                    for dict in readingsArray {
                                        
                                        let ob: NSDictionary = dict as! NSDictionary
                                        let conditionIndex: Int = ob.value(forKey: "conditionIndex")! as! Int
                                        
                                        if conditionIndex != -1 && i == conditionIndex {
                                            data[i] = ob.value(forKey: "reading")! as! CGFloat
                                            //commeented the break so that we can select the last value for a given index
//                                            break
                                        }
                                    }
                                    
                                }
                                self.dataArray.add(data)
                            }
                        }
//                        print("Data Array")
//                        print(self.dataArray)
                        self.resetUI()
                    }
                    else{
                        self.resetUI()
                    }
                    
                }
                
                break
            case .failure(let error):
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysConditionChart) Calling", action:"Fail - Web API Calling" , label:String(describing: error), value : self.formInterval.intervalAsSeconds())
                
                print("failure")
                self.resetUI()
                break
                
            }
        }
    }
}
    
    
    //MARK: - Notifications Methods
    func chartViewNotification(notification: NSNotification) {
       //getChartHistoryData(condition: conditionTxtFld.text!)
        if(conditionTxtFld.text! != "All conditions")
        {
            print("Condition text field")
            
            
            let tempString : [String] = conditionTxtFld.text!.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = conditionTxtFld.text!
            }
            getChartConditionData(condition: newCondition)
        }
        else{
            print("All conditions")
            print(conditionTxtFld.text!)
            getChartHistoryData(condition: conditionTxtFld.text!)
            
        }
        // self.drawChart()
    }
    
    func noOfDaysNotification(notification: NSNotification) {
        
        noOfDays = String(describing: notification.value(forKey: "object")!)
        print("noOfDays \(noOfDays)")
        //getChartHistoryData(condition: conditionTxtFld.text!)
        
        if(conditionTxtFld.text! != "All conditions")
        {
            print("Condition text field")
            
            
            let tempString : [String] = conditionTxtFld.text!.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = conditionTxtFld.text!
            }
            getChartConditionData(condition: newCondition)
        }
        else{
            print("All conditions")
            print(conditionTxtFld.text!)
            getChartHistoryData(condition: conditionTxtFld.text!)
            
        }
        
    }
    //MARK:- PickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return conditionsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return conditionsArray[row] as? String
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
   
    //MARK: - Custom Methods
    func setUI(){
        //        glucoseLbl.layer.cornerRadius = 5
        //        deviationLbl.layer.cornerRadius = 5
        conditionView.layer.cornerRadius = 10
        conditionView.layer.borderColor = Colors.PrimaryColor.cgColor
        conditionView.layer.borderWidth = 1
        
        pickerViewInner.layer.cornerRadius = 10
        pickerViewInner.layer.borderColor = Colors.PrimaryColor.cgColor
        pickerViewInner.layer.borderWidth = 1
        
        pickerViewContainer.layer.cornerRadius = 10
        pickerViewContainer.layer.borderColor = Colors.PrimaryColor.cgColor
        pickerViewContainer.layer.borderWidth = 1

        
        let blurEffect = UIBlurEffect(style: .dark)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = pickerViewContainer.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pickerViewContainer.insertSubview(blurEffectView, belowSubview: pickerViewInner)
        
        hyposLbl.layer.cornerRadius = 5
        hyperLbl.layer.cornerRadius = 5
        medianLabel.layer.cornerRadius = 5
        IQRLabel.layer.cornerRadius =  5
        hyposLbl.backgroundColor = Colors.PrimaryColor
        hyperLbl.backgroundColor = Colors.PrimaryColor
        medianLabel.backgroundColor = Colors.PrimaryColor
        IQRLabel.backgroundColor = Colors.PrimaryColor

        
        hyposLbl.textColor = UIColor.white
        hyperLbl.textColor = UIColor.white
        medianLabel.textColor = UIColor.white
        IQRLabel.textColor = UIColor.white
        //        glucoseView.isHidden = true
        //        standardDeviationView.isHidden = true
        
        //        glucoseLbl.layer.masksToBounds = true
        //        deviationLbl.layer.masksToBounds = true
        hyposLbl.layer.masksToBounds = true
        hyperLbl.layer.masksToBounds = true
        medianLabel.layer.masksToBounds = true
        IQRLabel.layer.masksToBounds = true
        
        chartView.layer.cornerRadius = kButtonRadius
        chartView.layer.borderWidth = 1
        chartView.layer.borderColor = Colors.PrimaryColor.cgColor
        chartView.layer.masksToBounds = true
        
        readingsView.layer.cornerRadius = kButtonRadius
        readingsView.layer.borderWidth = 1
        readingsView.layer.borderColor = Colors.PrimaryColor.cgColor
        readingsView.layer.masksToBounds = true
        
        addNotifications()
    }
    
    func addNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.chartViewNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.chartHistoryView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.noOfDaysNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
    }
    
   
    
    
    func setBottomLabels(dataArrayLabels: [CGFloat]){
        var sum : CGFloat = 0.0
        var numHypos = 0
        var numHypers = 0
        
        var dataSorted = dataArrayLabels.sorted()
        
        if selectedConditionIndex > 0
        {
            if(dataSorted.count >= 2)
            {
                var median : CGFloat = 0.0
                let middle = dataSorted.count/2
                var firstPrecentileArray : [CGFloat] = []
                var thirdPrecentileArray : [CGFloat] = []
            
                if dataSorted.count % 2 == 0{
                    for index in 0..<middle
                    {
                        firstPrecentileArray.append(dataSorted[index])
                    }
                    for index in (middle)..<dataSorted.count
                    {
                        thirdPrecentileArray.append(dataSorted[index])
                    }
                }
                else
                {
                    for index in 0..<middle
                    {
                        firstPrecentileArray.append(dataSorted[index])
                    }
                    for index in (middle+1)..<dataSorted.count
                    {
                        thirdPrecentileArray.append(dataSorted[index])
                    }
                }
            
                let middleElementQ1 = firstPrecentileArray[firstPrecentileArray.count/2]
                let middleElementQ3 = thirdPrecentileArray[thirdPrecentileArray.count/2]
            
                if middleElementQ3 == 0.0{
                    IQRLabel.text = "\(middleElementQ1)"
                }
                else if middleElementQ1 == 0.0{
                    IQRLabel.text = "\(middleElementQ3)"
            }
            else{
                    IQRLabel.text = "\(middleElementQ3 -  middleElementQ1)"
                }
            }
            else{
                if(dataSorted[0] != 0.0)
                {
                    IQRLabel.text = "\(dataSorted[0])"
                }
            }
        }
        else{
            IQRLabel.text = "N/A"
        }
        
        for i in 0..<dataArrayLabels.count{
            sum = sum + CGFloat(dataArrayLabels[i])
            
            if(dataArrayLabels[i]>180.0){
                numHypers = numHypers + 1
                //print("Data Array")
                //print(dataArrayLabels[i])
            }
            else if(dataArrayLabels[i]<70.2){
                numHypos = numHypos + 1
            }
            
            
        }
        
        hyposLbl.text = "\(numHypos)"
        hyperLbl.text = "\(numHypers)"
        
    }
    
    func drawChartCondition(dateArray: NSArray){
        
        var medianArray: [CGFloat] = []
        //  var medianModels: [(x: Double, y: Double, type: MyExampleModelDataType)] = []
        var medianLineData: [(x: Double, y: Double)] = []
        
        var medianMaxData: [(x: Double, y: Double)] = []
        var medianMinData: [(x: Double, y: Double)] = []
        var medianIndex : Int = 0
        
        let dataMedianArray : NSMutableArray = NSMutableArray()
        
        for index in 0..<dateArray.count{
            var tempArray : [CGFloat] = []
            for data in dataArray{
                let dataAr: [CGFloat] = data as! Array
                if(dataAr[index] != 0.0)
                {
                    tempArray.append(dataAr[index])
                }
            }
            if(tempArray.count == 0)
            {
                tempArray.append(0.0)
            }
            dataMedianArray.add(tempArray)
        }
        
        medianMaxData.append((Double(0),Double(180)))
        medianMinData.append((Double(0),Double(80)))
        
        for dataM in dataMedianArray
        {
            let dataMAr: [CGFloat] = dataM as! Array
            
            var dataSorted = dataMAr.sorted()
            
            if(dataSorted.count >= 2)
            {
                var median : CGFloat = 0.0
                let middle = dataSorted.count/2
                
                
                if middle%2 == 0{
                    median = (dataSorted[middle] + dataSorted[middle-1])/2
                }
                else{
                    median = dataSorted[middle]
                    
                    
                }
                medianArray.append(median)
                //medianModels.append((Double(medianIndex+1),Double(median), .type2))
                
                if(median != 0.0)
                {
                    medianLineData.append((Double(medianIndex),Double(median)))
                }
                medianMaxData.append((Double(medianIndex),Double(180)))
                medianMinData.append((Double(medianIndex),Double(80)))
                medianIndex += 1
                
            }
            else{
                
                
                if(dataSorted[0] != 0.0)
                {
                    medianLineData.append((Double(medianIndex),Double(dataSorted[0])))
                    
                }
                medianMaxData.append((Double(medianIndex),Double(180)))
                medianMinData.append((Double(medianIndex),Double(80)))
                medianIndex += 1
                
            }
        }
        
        medianMaxData.remove(at: medianMaxData.count-1)
        medianMinData.remove(at: medianMinData.count-1)
        
        let currentMedianIndex = medianLineData.count/2
        let currentMedian = medianLineData[currentMedianIndex].y
        medianLabel.text = "\(currentMedian)"
        
        var dataArrayLabels : [CGFloat] = []
        var models: [(x: Double, y: Double, type: MyExampleModelDataType)] = []
        
        for data in dataArray {
            
            let dataAr: [CGFloat] = data as! Array
            
            for i in 0..<dataAr.count{
                if(dataAr[i] != 0.0)
                {
                    if(dataAr[i] < 70.2)
                    {
                        models.append((Double(i),Double(dataAr[i]), .type4))
                    }
                    else if(dataAr[i] > 180.0)
                    {
                        models.append((Double(i),Double(dataAr[i]), .type4))
                    }
                    else{
                        models.append((Double(i),Double(dataAr[i]), .type5))
                    }
                    
                    //lineData .append((Double(i+1),Double(dataAr[i])))
                    dataArrayLabels.append(dataAr[i])
                }
            }
        }
        
        setBottomLabels(dataArrayLabels:dataArrayLabels)
        let maxMedian = models.max { $0.y < $1.y }
        //        let roundVal = ceil((maxMedian?.y)! / 6)
        let roundVal = Double(40)
        var maxVal = (maxMedian?.y)! + roundVal
        maxVal = maxVal >= 180 ? maxVal : 200
        //        maxVal = maxVal + 50
        maxVal = 320
        
        let labelSettings = ChartLabelSettings(font:UIFont(name: "Helvetica", size: 12)!)
        
        let layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)] = [
            .type0 : (.triangle, UIColor.red),
            .type1 : (.square, UIColor.black),
            .type2 : (.circle, UIColor.black),
            .type3 : (.cross, UIColor.black),
            .type4 : (.circle, Colors.chartHyperHypoColor),
            .type5 : (.circle, Colors.chartNormalColor)
        ]
        
        let xValues = dateArray.enumerated().map {index, tuple in ChartAxisValueString(dateArray[index] as! String, order: index, labelSettings: labelSettings)}
        
        let yValues = stride(from: 0 , through: maxVal, by: roundVal).map {ChartAxisValueDouble($0, labelSettings: labelSettings)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "", settings: labelSettings.defaultVertical()))
        
        let chartFrame = ExamplesDefaults.chartFrame(self.chartView.bounds)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let scatterLayers = self.toLayers(models, layerSpecifications: layerSpecifications, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame)
        
        //set guide lines
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: 1.5)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: guidelinesLayerSettings)
        
        //        print("Median Line Data")
        //        print(medianLineData)
        let chartPoints: [ChartPoint] = medianLineData.map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettings), y: ChartAxisValueDouble($0.1))}
        
        let trendLineModel = ChartLineModel(chartPoints: TrendlineGenerator.trendline(chartPoints),lineColor: Colors.outgoingMsgColor, lineWidth : 2.0, animDuration: 0.5, animDelay: 1)
        let trendLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [trendLineModel])
        
        
        // Set Max Value line
        let lineMaxChartPoints = medianMaxData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(index), y: ChartAxisValueDouble(tuple.y))}
        let lineMaxModel = ChartLineModel(chartPoints: lineMaxChartPoints, lineColor: UIColor.darkGray, lineWidth: 2, animDuration: 0.3, animDelay: 1)
        let lineMaxLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineMaxModel])
        
        // Set Min Value line
        let lineMinChartPoints = medianMinData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(index), y: ChartAxisValueDouble(tuple.y))}
        let lineMinModel = ChartLineModel(chartPoints: lineMinChartPoints, lineColor: UIColor.darkGray, lineWidth: 2, animDuration: 0.3, animDelay: 1)
        let lineMinLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineMinModel])
        
        //tuple.x and tuple.y plots the x-coordinate and y-coordinate
        let lineChartPoints = medianLineData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(tuple.x), y: ChartAxisValueDouble(tuple.y))}
        let lineModel = ChartLineModel(chartPoints: lineChartPoints, lineColor: Colors.DHTabBarGreen, lineWidth: 4, animDuration: 0.3, animDelay: 0.6)
        let lineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                lineMaxLayer,
                lineMinLayer,
                lineLayer,
                ] + scatterLayers
        )
        
        self.chartView.subviews.forEach({ $0.removeFromSuperview() })
        self.chartView.addSubview(chart.view)
        self.chart = chart
        
    }

    
    
    func drawChart(){
        
        
        var medianArray: [CGFloat] = []
      //  var medianModels: [(x: Double, y: Double, type: MyExampleModelDataType)] = []
        var medianLineData: [(x: Double, y: Double)] = []
       
        var medianMaxData: [(x: Double, y: Double)] = []
        var medianMinData: [(x: Double, y: Double)] = []
        var medianIndex : Int = 0
        
        // PREPARING THE ARRAY FOR FINDING MEDIAN
        let dataMedianArray : NSMutableArray = NSMutableArray()
        
        for index in 0..<chartConditionsArray.count{
            var tempArray : [CGFloat] = []
            for data in dataArray{
//                print("Data array")
//                print(data)
                let dataAr: [CGFloat] = data as! Array
                if(dataAr[index] != 0.0)
                {
                    tempArray.append(dataAr[index])
                }
            }
            if(tempArray.count == 0)
            {
                tempArray.append(0.0)
            }
            dataMedianArray.add(tempArray)
        }
        
        medianMaxData.append((Double(0),Double(180)))
        medianMinData.append((Double(0),Double(80)))
        
        
//       medianLineData.append((Double(0),Double(0)))
        // CREATING MEDIAN ARRAY
        for dataM in dataMedianArray
        {
            let dataMAr: [CGFloat] = dataM as! Array
            
            var dataSorted = dataMAr.sorted()
            
            if(dataSorted.count >= 2)
            {
                var median : CGFloat = 0.0
                let middle = dataSorted.count/2
                
                
                if middle%2 == 0{
                    median = (dataSorted[middle] + dataSorted[middle-1])/2
                }
                else{
                    median = dataSorted[middle]
                }
                medianArray.append(median)
                //medianModels.append((Double(medianIndex+1),Double(median), .type2))
                
                if(median != 0.0)
                {
                    medianLineData.append((Double(medianIndex),Double(median)))
                }
                    medianMaxData.append((Double(medianIndex),Double(180)))
                    medianMinData.append((Double(medianIndex),Double(80)))
                medianIndex += 1
               
            }
            else{
                

                if(dataSorted[0] != 0.0)
                {
                 medianLineData.append((Double(medianIndex),Double(dataSorted[0])))
                 
                }
                medianMaxData.append((Double(medianIndex),Double(180)))
                medianMinData.append((Double(medianIndex),Double(80)))
                medianIndex += 1
               
              }
        }
        
        medianMaxData.remove(at: medianMaxData.count-1)
        medianMinData.remove(at: medianMinData.count-1)
        
        let currentMedianIndex = medianLineData.count/2
        let currentMedian = medianLineData[currentMedianIndex].y
        medianLabel.text = "\(currentMedian)"
        
        var dataArrayLabels : [CGFloat] = []
        
        var models: [(x: Double, y: Double, type: MyExampleModelDataType)] = []
        for data in dataArray {
            
            let dataAr: [CGFloat] = data as! Array
            
            for i in 0..<dataAr.count{
                if(dataAr[i] != 0.0)
                {
                    if(dataAr[i] < 70.2)
                    {
                        models.append((Double(i),Double(dataAr[i]), .type4))
                    }
                    else if(dataAr[i] > 180.0)
                    {
                        models.append((Double(i),Double(dataAr[i]), .type4))
                    }
                    else{
                        models.append((Double(i),Double(dataAr[i]), .type5))
                    }
                    
                    //lineData .append((Double(i+1),Double(dataAr[i])))
                    dataArrayLabels.append(dataAr[i])
                }
            }
        }
        setBottomLabels(dataArrayLabels:dataArrayLabels)
        let maxMedian = models.max { $0.y < $1.y }
//        let roundVal = ceil((maxMedian?.y)! / 6)
        let roundVal = Double(40)
        var maxVal = (maxMedian?.y)! + roundVal
        maxVal = maxVal >= 180 ? maxVal : 200
//        maxVal = maxVal + 50
        maxVal = 320
        
        let labelSettings = ChartLabelSettings(font:UIFont(name: "Helvetica", size: 12)!)
        
        let layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)] = [
            .type0 : (.triangle, UIColor.red),
            .type1 : (.square, UIColor.black),
            .type2 : (.circle, UIColor.black),
            .type3 : (.cross, UIColor.black),
            .type4 : (.circle, Colors.chartHyperHypoColor),
            .type5 : (.circle, Colors.chartNormalColor)
        ]
        
        // Set X, Y cordinates with scatter layers
        let xValues = chartConditionsArray.enumerated().map {index, tuple in ChartAxisValueString(chartConditionsArray[index] as! String, order: index, labelSettings: labelSettings)}
        
        let yValues = stride(from: 0 , through: maxVal, by: roundVal).map {ChartAxisValueDouble($0, labelSettings: labelSettings)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "", settings: labelSettings.defaultVertical()))
        
        let chartFrame  = ExamplesDefaults.chartFrame(self.chartView.bounds)
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let scatterLayers = self.toLayers(models, layerSpecifications: layerSpecifications, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame)
        
        //set guide lines
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.darkGray, linesWidth: 1.5)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: guidelinesLayerSettings)
        
//        print("Median Line Data")
//        print(medianLineData)
        let chartPoints: [ChartPoint] = medianLineData.map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettings), y: ChartAxisValueDouble($0.1))}
        
        let trendLineModel = ChartLineModel(chartPoints: TrendlineGenerator.trendline(chartPoints),lineColor: Colors.outgoingMsgColor, lineWidth : 2.0, animDuration: 0.5, animDelay: 1)
        let trendLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [trendLineModel])
        
        // Set Max Value line
        let lineMaxChartPoints = medianMaxData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(index), y: ChartAxisValueDouble(tuple.y))}
        let lineMaxModel = ChartLineModel(chartPoints: lineMaxChartPoints, lineColor: Colors.PrimaryColor, lineWidth: 2, animDuration: 0.3, animDelay: 1)
        let lineMaxLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineMaxModel])
        
        // Set Min Value line
        let lineMinChartPoints = medianMinData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(index), y: ChartAxisValueDouble(tuple.y))}
        let lineMinModel = ChartLineModel(chartPoints: lineMinChartPoints, lineColor: Colors.PrimaryColor, lineWidth: 2, animDuration: 0.3, animDelay: 1)
        let lineMinLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineMinModel])
        
        //tuple.x and tuple.y plots the x-coordinate and y-coordinate
        let lineChartPoints = medianLineData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(tuple.x), y: ChartAxisValueDouble(tuple.y))}
        let lineModel = ChartLineModel(chartPoints: lineChartPoints, lineColor: Colors.DHTabBarGreen, lineWidth: 4, animDuration: 0.3, animDelay: 0.6)
        let lineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                lineMaxLayer,
                lineMinLayer,
                lineLayer,
                ] + scatterLayers
        )
        
       
        self.chartView.subviews.forEach({ $0.removeFromSuperview() })
        self.chartView.addSubview(chart.view)
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            //self.chartView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        self.chart = chart
        
    }
    
    
}


//
//  ChartViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 30/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import QuartzCore

class ChartViewController: UIViewController, LineChartDelegate {

    @IBOutlet weak var glucoseLbl: UILabel!
    @IBOutlet weak var deviationLbl: UILabel!
    @IBOutlet weak var hyposLbl: UILabel!
    @IBOutlet weak var hyperLbl: UILabel!
    @IBOutlet weak var hbaLbl: UILabel!
    @IBOutlet weak var chartView: UIView!
    
    var label = UILabel()
    var lineChart: LineChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUI()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.chartHistoryView), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Notifications Methods
    func chartViewNotification(notification: NSNotification) {
        self.drawChart()
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
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.chartViewNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.chartHistoryView), object: nil)
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
        chartView.addSubview(label)
        views["label"] = label
        chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
        chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[label]", options: [], metrics: nil, views: views))
        
        // simple arrays
        let data: [CGFloat] = [3, 4, 2, 11, 13, 15]
        //let data2: [CGFloat] = [1, 3, 5, 13, 17, 20]
        
        // simple line with custom x axis labels
        let xLabels: [String] = ["","18th", "19th", "20th", "21st", "22nd", "23rd","24th"]
        let yLabels: [String] = ["0","30","60","90","120","150"]
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = 7
        lineChart.y.grid.count = 6
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
        //lineChart.y.labels.values = yLabels
        lineChart.addLine(data)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        chartView.addSubview(lineChart)
        views["chart"] = lineChart
        chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
        chartView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
        
    }
    
    /**
     * Line chart delegate method.
     */
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
       // label.text = "x: \(x)     y: \(yValues)"
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

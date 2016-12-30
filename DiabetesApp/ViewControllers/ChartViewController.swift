//
//  ChartViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 30/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {

    @IBOutlet weak var glucoseLbl: UILabel!
    @IBOutlet weak var deviationLbl: UILabel!
    @IBOutlet weak var hyposLbl: UILabel!
    @IBOutlet weak var hyperLbl: UILabel!
    @IBOutlet weak var hbaLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

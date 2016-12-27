//
//  CarePlanViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 26/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class CarePlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tblView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segment Control Methods
    @IBAction func SegmentControl_ValueChanged(_ sender: Any) {
        tblView.reloadData()
    }
    
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = (segmentControl.selectedSegmentIndex == 0 ? "medicationCell" : "readingsCell")
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)! as UITableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return (segmentControl.selectedSegmentIndex == 0 ? 200 : 174)
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

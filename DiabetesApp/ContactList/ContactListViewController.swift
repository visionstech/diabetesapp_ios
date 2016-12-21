//
//  ContactListViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 12/21/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class ContactListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var patientList = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj: ContactObj = patientList[indexPath.row] as! ContactObj
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath)
        if obj.isSelected == "1" {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = obj.full_name

        
        return cell
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

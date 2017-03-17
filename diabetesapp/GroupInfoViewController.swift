//
//  GroupInfoViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 3/17/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class GroupInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupName: UILabel!
    var UserGroupName =  String()
    
    var userArray = NSMutableArray()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        groupName.text = UserGroupName

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return userArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView .dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = (userArray[indexPath.row] as AnyObject).value(forKey: "login") as? String
        cell.imageView?.image =  UIImage(named: "user.png")
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

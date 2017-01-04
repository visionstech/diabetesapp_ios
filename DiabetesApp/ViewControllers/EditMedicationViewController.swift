//
//  EditMedicationViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class EditMedicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var addMedicineView: UIView!
    @IBOutlet weak var addMedicineBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    var array = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       // setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        setUI()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func setUI(){
       
        let backBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action:  #selector(BackBtn_Click))
       
        self.tabBarController?.navigationItem.title = "\("CARE_PLAN".localized)"
        self.title = "\("CARE_PLAN".localized)"
        
        // for Patient Login
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = backBtn
        
        // for doctor login
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.hidesBackButton = true
        
        self.setCorners(view: addMedicineView, createShadow: true)
        self.setCorners(view: saveBtn, createShadow: true)
        self.setCorners(view: addMedicineBtn, createShadow: false)
        tblView.tableFooterView = UIView()
        
        addMedicineObj()
        
    }
    
    func setCorners(view: UIView, createShadow: Bool)
    {
        // Corner radius
        view.layer.cornerRadius = 8
        view.layer.cornerRadius = 8
        
        if createShadow == true {
            // Shadow on view
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 2
        }
    }
    
    func addMedicineObj(){
        
        let obj = CarePlanObj()
        obj.id = ""
        obj.name = ""
        obj.dosage = ""
        obj.frequency = ""
        array.add(obj)
        
        tblView.insertRows(at: [IndexPath(row: array.count-1, section: 0) as IndexPath], with: .none)
        tblView.scrollToRow(at: IndexPath(row: array.count-1, section: 0) as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    // MARK: - IBAction Methods
    @IBAction func AddMedicine_Click(_ sender: Any) {
        addMedicineObj()
    }
    
    
    @IBAction func SaveBtn_Click(_ sender: Any) {
        
    }

    func BackBtn_Click(){
        //self.tabBarController?.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell")! 
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 202
    }
    
    // MARK: - TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
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

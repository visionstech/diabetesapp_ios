//
//  PatientInfoViewController.swift
//  DiabetesApp
//
//  Created by User on 1/12/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import Foundation
import UIKit
//import AlamofireImage
import Alamofire
import SDWebImage

class InfoCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
   //    @IBOutlet weak var itemLabel: UILabel!
//    @IBOutlet weak var itemValue: UILabel!
    
    @IBOutlet weak var itemValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated);
    }
    
}

class PatientInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
      
    
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var infoTable: UITableView!
    @IBOutlet weak var infoImageView: UIImageView!
    let bioData: [String]               = ["Name".localized, "HC#".localized, "Sex".localized, "Age".localized, "BMI".localized];
    let diseaseDetail: [String]         = ["Diabetec".localized, "Duration".localized, "Cholestrol".localized, "HbA1c", "Other diseases".localized];
    let sectionNum_bioData: Int         = 0;
    let sectionNum_diseaseDetail: Int   = 1;
    let numberOfSections: Int           = 2;
    let sectionTitle_bioData            = "Bio Data".localized;
    let sectionTitle_diseaseDetail      = "Disease Details".localized;
    
    var bioDataValues: [String] = []
    var diseaseDataValues: [String] = []
    
    var isDone : Bool = false
    
    let selectedPatientID : String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
    let typeUser : Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    var topBackView:UIView = UIView()
    var formInterval: GTInterval!
    var currentLocale: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        infoTable.delegate = self;
        infoTable.dataSource = self;
        infoTable.backgroundColor = UIColor.clear
        photoView.backgroundColor = UIColor.clear
        currentLocale = NSLocale.current.languageCode!
        
      
        infoImageView.layer.cornerRadius = infoImageView.frame.size.width/2;
        infoImageView.layer.masksToBounds = true;
        
        let tapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        infoImageView.isUserInteractionEnabled = true
        infoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        let parametersUser: Parameters = [
            "userid": selectedPatientID,
            "type": "Patient"
        ]
       
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getUserProfile)", method: .post, parameters: parametersUser, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            print("Validation Successful \(response.result.value)")
            switch response.result {
            case .success:
                
                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                    self.bioDataValues.append(JSON.value(forKey:"name") as! String)
                    self.bioDataValues.append(JSON.value(forKey:"HCNumber") as! String)
                    self.bioDataValues.append(JSON.value(forKey:"sex") as! String)
                    self.bioDataValues.append(JSON.value(forKey:"age") as! String)
                    self.bioDataValues.append(JSON.value(forKey:"bmi") as! String)
//                    self.bioDataValues.append(JSON.value(forKey:"height") as! String)
                    //                    self.bioDataValues.append(JSON.value(forKey:"doctors") as! String)
                    //                    self.bioDataValues.append(JSON.value(forKey:"educators") as! String)
                    
                    self.diseaseDataValues.append(JSON.value(forKey:"diabetic") as! String)
                    self.diseaseDataValues.append(JSON.value(forKey:"duration") as! String)
                    self.diseaseDataValues.append(JSON.value(forKey:"cholestrol") as! String)
                    self.diseaseDataValues.append(JSON.value(forKey:"hba1c") as! String)
                    self.diseaseDataValues.append(JSON.value(forKey:"other_diseases") as! String)
                     GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getUserProfile) Calling", action:"Success - Web API Calling" , label:"get User Profile", value : self.formInterval.intervalAsSeconds())
                    
                    Alamofire.request("http://54.212.229.198:3000/showImage?id="+self.selectedPatientID+"&type=Patient", method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
                        
                        //            print(response.result.value)
                        let finalresult = response.result.value as! NSDictionary
                        if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                            
                            //print("JSON: \(JSON)")
                            let imageName: String = JSON.value(forKey:"profileimage") as! String
                            
                            let imagePath = "http://54.212.229.198:3000/upload/" + imageName
                            let manager:SDWebImageManager = SDWebImageManager.shared()
                            
                            manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                                                  options: SDWebImageOptions.highPriority,
                                                  progress: nil,
                                                  completed: {[weak self] (image, error, cached, finished, url) in
                                                    if (error == nil && (image != nil) && finished) {
                                                        // do something with image
                                                        self?.infoImageView.image=image
                                                    }
                            })
                            
                            print(imagePath)
                        }
                        
                    }
                    
                    
                    self.isDone = true
                    DispatchQueue.main.async {
                        self.infoTable.reloadData()
                    }
                }
                
                break
           case .failure(let error):
                print("failure")
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getUserProfile) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                break
                
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
    }
       
    override func viewWillAppear(_ animated: Bool) {
        
        setNavBarUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kPatientInfoScreenName)
        //--------Google Analytics Finish-----
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Top View
    func createCustomTopView() {
        
        topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
        topBackView.addGestureRecognizer(tapGesture)
        topBackView.isUserInteractionEnabled = true
        
        self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
        self.navigationController?.navigationBar.addSubview(topBackView)
    }
    
    // MARK: - Custom Methods
    
    func BackBtn_Click(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setNavBarUI(){
        
        self.title = "\("PATIENT_INFO".localized)"
        self.tabBarController?.title = "\("PATIENT_INFO".localized)"
        self.tabBarController?.navigationItem.title = "\("PATIENT_INFO".localized)"
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        createCustomTopView()
        
        
    }

    // MARK: - Actions for buttons
    @IBAction func onBack(sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true);
    }
    
    // MARK: - TableView datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int = 0;
        
        if (section == sectionNum_bioData) {
            rowCount = bioData.count;
        } else if (section == sectionNum_diseaseDetail) {
            rowCount = diseaseDetail.count;
        }
        
        return rowCount;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let infoCell: InfoCell = infoTable.dequeueReusableCell(withIdentifier: "infoCell") as! InfoCell;
        
        if currentLocale == "ar"
        {
            infoCell.itemLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        }
        
        if(isDone)
        {
            if (indexPath.section == sectionNum_bioData) {
                print(indexPath.row)
                infoCell.itemLabel?.text = bioData[indexPath.row];
                infoCell.itemValue?.text = bioDataValues[indexPath.row];
            } else if (indexPath.section == sectionNum_diseaseDetail) {
                infoCell.itemLabel?.text = diseaseDetail[indexPath.row];
                infoCell.itemValue?.text = diseaseDataValues[indexPath.row];
            }
        }
        return infoCell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String = "";
        if (section == sectionNum_bioData) {
            title = sectionTitle_bioData;
        } else if (section == sectionNum_diseaseDetail) {
            title = sectionTitle_diseaseDetail;
        }
        
        return title;
    }
    
}

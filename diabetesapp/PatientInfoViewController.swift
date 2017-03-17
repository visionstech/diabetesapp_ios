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

class PatientInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate {
    
      
    
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var infoTable: UITableView!
    @IBOutlet weak var infoImageView: UIImageView!
    let bioData: [String]               = ["Name".localized, "HC#".localized, "Sex".localized, "Age".localized, "BMI".localized];
    var diseaseDetail: [String]         = []
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
    var newImageView : UIImageView = UIImageView()
    
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
                
                   
                    
                    let stringDuration : String = JSON.value(forKey:"duration") as! String
                    var stringDurationSplit : [String] = stringDuration.components(separatedBy: " ")
                    var newDurationString : String = ""
                    if stringDuration.length<1  {
                         newDurationString = "-"
                    }
                    else if stringDurationSplit.count > 2
                    {
                        if stringDurationSplit[0] != "1" && stringDurationSplit[2] != "1"
                        {
                        newDurationString = stringDurationSplit[0] + " years ".localized + stringDurationSplit[2] + " months".localized
                        }
                        else if stringDurationSplit[0] == "1" && stringDurationSplit[2] != "1"
                        {
                            newDurationString = stringDurationSplit[0] + " year ".localized + stringDurationSplit[2] + " months".localized
                        }
                        else if stringDurationSplit[0] != "1" && stringDurationSplit[2] == "1"
                        {
                            newDurationString = stringDurationSplit[0] + " years ".localized + stringDurationSplit[2] + " month".localized
                        }
                        else if stringDurationSplit[0] == "1" && stringDurationSplit[2] == "1"
                        {
                            newDurationString = stringDurationSplit[0] + " year ".localized + stringDurationSplit[2] + " month".localized
                        }
                    }
                    else{
                            if stringDurationSplit[0] != "1"
                            {
                                newDurationString = stringDurationSplit[0] + " years ".localized
                            }
                            else if stringDurationSplit[0] == "1"
                            {
                                newDurationString = stringDurationSplit[0] + " year ".localized
                            }
                        // newDurationString = stringDurationSplit[0] + " years".localized
                    }
                    
                    let gender = JSON.value(forKey:"sex") as! String
                    
                    if let deliveryDate = JSON.value(forKey:"deliveryDate"){
                    
                    }
                    if gender.lowercased() == "female"{
                        if let deliveryDate = JSON.value(forKey:"deliveryDate"){
                            self.diseaseDetail =  ["Gestation Period".localized, "Diabetec".localized, "Duration".localized, "Ultrasound".localized, "HbA1c", "Other diseases".localized];
                            self.diseaseDataValues.append(deliveryDate as! String)
                        }
                        else{
                            self.diseaseDetail =  ["Diabetec".localized, "Duration".localized, "Cholestrol".localized, "HbA1c", "Other diseases".localized];
                        }
                    }
                    else{
                        self.diseaseDetail =  ["Diabetec".localized, "Duration".localized, "Cholestrol".localized, "HbA1c", "Other diseases".localized];
                    }
                    self.diseaseDataValues.append(JSON.value(forKey:"diabetic") as! String)
                    self.diseaseDataValues.append(newDurationString)
                    if let cholestrol = JSON.value(forKey:"cholestrol"){
                        self.diseaseDataValues.append(JSON.value(forKey:"cholestrol") as! String)
                    }
                    else if let ultrasound = JSON.value(forKey:"ultrasound"){
                        
                        self.diseaseDataValues.append(JSON.value(forKey:"ultrasound") as! String)
                    }
                    
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
                                                    else{
                                                        self?.infoImageView.image = UIImage(named:"placeholder.png")
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
        let scrollV:UIScrollView = UIScrollView()
        scrollV.frame = self.view.frame
        scrollV.minimumZoomScale=1.0
        scrollV.maximumZoomScale=6.0
        scrollV.bounces=false
        scrollV.delegate=self;
        self.view.addSubview(scrollV)
        
        let imageView = sender.view as! UIImageView
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = scrollV.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode =  .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        scrollV.addSubview(newImageView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return newImageView
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
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            topBackView = UIView(frame: CGRect(x: self.view.frame.size.width - 90, y: 0, width: 75, height: 40))
            //            topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topbackArbic")!)
            let backImg : UIImageView = UIImageView(frame:CGRect( x: 45, y: 8, width: 40, height: 25))
            backImg.image = UIImage(named:"topbackArbic")
            topBackView.addSubview(backImg)
            
            let userImgView: UIImageView = UIImageView(frame: CGRect(x: 2 , y: 3, width: 34, height: 34))
            //userImgView.image = UIImage(named: "user.png")
            topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
            
            
        }
        else {
            
            topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 84, height: 40))
            //            topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
            let backImg : UIImageView = UIImageView(frame:CGRect( x: 2, y: 8, width: 40, height: 25))
            backImg.image = UIImage(named:"topBackBtn")
            topBackView.addSubview(backImg)
            
         //   let userImgView: UIImageView = UIImageView(frame: CGRect(x: 40, y: 3, width: 34, height: 34))
            //userImgView.image = UIImage(named: "user.png")
           // topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
        }
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

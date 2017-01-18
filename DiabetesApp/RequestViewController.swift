//
//  RequestViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 1/13/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
      setNavBarUI()
        // Do any additional setup after loading the view.
    }
    
//    // MARK: - Custom Top View
//    func createCustomTopView() {
//        
//        topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 40))
//        topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
//        let userImgView: UIImageView = UIImageView(frame: CGRect(x: 35, y: 3, width: 34, height: 34))
//        userImgView.image = UIImage(named: "user.png")
//        topBackView.addSubview(userImgView)
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
//        topBackView.addGestureRecognizer(tapGesture)
//        topBackView.isUserInteractionEnabled = true
//        
//        self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
//        self.navigationController?.navigationBar.addSubview(topBackView)
//    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        
        self.title = "\("Requests".localized)"
        self.tabBarController?.title = "\("Requests".localized)"
        self.tabBarController?.navigationItem.title = "\("Requests".localized)"
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        //createCustomTopView()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return 5
    }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell: RequestTableViewCell = tableView.dequeueReusableCell(withIdentifier: "requestCell")! as! RequestTableViewCell
    
    return cell;
    
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

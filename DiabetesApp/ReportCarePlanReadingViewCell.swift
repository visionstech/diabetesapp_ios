//
//  ReportCarePlanReadingViewCell.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class ReportCarePlanReadingViewCell: UITableViewCell {

    @IBOutlet weak var conditionLbl: UITextField!
       
   
    @IBOutlet weak var goalLbl: UITextField!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setUI(view: mainView)
        //self.setUI(view: headerView)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUI(view: UIView)
    {
        // Corner radius
       
        /* view.layer.cornerRadius = 8
        view.layer.cornerRadius = 8
        
        // Shadow on view
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 3*/
        
    }
    
}

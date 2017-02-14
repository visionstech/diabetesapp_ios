//
//  CarePlanReadingHeaderTableViewCell.swift
//  DiabetesApp
//
//  Created by IOS4 on 05/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class CarePlanReadingHeaderTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var frequencyLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var timingHeaderLabel: UILabel!
    
    @IBOutlet weak var goalHeaderLabel: UILabel!
     @IBOutlet weak var btnEdit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUI(view: headerView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUI(view: UIView)
    {
        // Corner radius
//        view.layer.cornerRadius = 8
//        view.layer.cornerRadius = 8
//        
//        // Shadow on view
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.5
//        view.layer.shadowOffset = CGSize.zero
//        view.layer.shadowRadius = 3
        
        timingHeaderLabel.text = "CONDITION".localized
        goalHeaderLabel.text = "Goal".localized
        frequencyLbl.text = "Frequency".localized
        
    }

}

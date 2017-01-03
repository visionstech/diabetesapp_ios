//
//  CarePlanReadingTableViewCell.swift
//  DiabetesApp
//
//  Created by IOS4 on 29/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class CarePlanReadingTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var conditionLbl: UILabel!
    @IBOutlet weak var frequencyLbl: UILabel!
    @IBOutlet weak var goalLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setUI(view: mainView)
        self.setUI(view: headerView)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUI(view: UIView)
    {
        // Corner radius
        view.layer.cornerRadius = 8
        view.layer.cornerRadius = 8
        
        // Shadow on view
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 3
        
    }

}

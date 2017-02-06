//
//  CarePlanFrequencyHeaderTableViewCell.swift
//  DiabetesApp
//
//  Created by Carisa Antariksa on 2/2/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class CarePlanFrequencyHeaderTableViewCell: UITableViewCell {

    //@IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var reqReadings: UILabel!
    //@IBOutlet weak var goalLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        reqReadings.text = "Required readings".localized
        // Configure the view for the selected state
    }


}

//
//  CarePlanFrequencyTableViewCell.swift
//  DiabetesApp
//
//  Created by Carisa Antariksa on 2/2/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class CarePlanFrequencyTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var numberLbl: UILabel!
    
    @IBOutlet weak var conditionLbl: UILabel!
    
    @IBOutlet weak var goalLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

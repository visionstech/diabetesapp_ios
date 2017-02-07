//
//  ReportMedicationTableViewCell.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit


class ReportMedicationTableViewCell: UITableViewCell {

    @IBOutlet weak var dosageTxtFld: UITextField!
    @IBOutlet weak var medNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

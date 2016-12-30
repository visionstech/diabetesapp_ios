//
//  CarePlanMedicationTableViewCell.swift
//  DiabetesApp
//
//  Created by IOS4 on 29/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class CarePlanMedicationTableViewCell: UITableViewCell {

    @IBOutlet weak var medImageView: UIImageView!
    @IBOutlet weak var medNameLbl: UILabel!
    @IBOutlet weak var dosageTxtFld: UITextField!
    @IBOutlet weak var conditionTxtFld: UITextField!
    @IBOutlet weak var frequencyTxtFld: UITextField!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Corner radius
        conditionTxtFld.layer.cornerRadius = 5
        dosageTxtFld.layer.cornerRadius = 5
        frequencyTxtFld.layer.cornerRadius = 5
        mainView.layer.cornerRadius = 8
        
        // Left margins
        setleftpadding(textfield: conditionTxtFld)
        setleftpadding(textfield: dosageTxtFld)
        setleftpadding(textfield: frequencyTxtFld)
        
        // Shadow on view
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 1
        mainView.layer.shadowOffset = CGSize.zero
        mainView.layer.shadowRadius = 5

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setleftpadding(textfield: UITextField)
    {
        textfield.leftViewMode = UITextFieldViewMode.always
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 15, height: 10)
        textfield.leftView = leftView
        
    }

}

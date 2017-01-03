//
//  CarePlanMedicationTableViewCell.swift
//  DiabetesApp
//
//  Created by IOS4 on 29/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class CarePlanMedicationTableViewCell: UITableViewCell {

    @IBOutlet weak var medicineNameTxtFld: UITextField!
    @IBOutlet weak var medImageView: UIImageView!
    @IBOutlet weak var medNameLbl: UILabel!
    @IBOutlet weak var dosageTxtFld: UITextField!
    @IBOutlet weak var conditionTxtFld: UITextField!
    @IBOutlet weak var frequencyTxtFld: UITextField!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mainView.layer.cornerRadius = 8
        
        // Left margins
        setleftpadding(textfield: conditionTxtFld)
        setleftpadding(textfield: dosageTxtFld)
        setleftpadding(textfield: frequencyTxtFld)
        if medicineNameTxtFld != nil {
            setleftpadding(textfield: medicineNameTxtFld)
        }
        
        // Shadow on view
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowOffset = CGSize.zero
        mainView.layer.shadowRadius = 3

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setleftpadding(textfield: UITextField)
    {
        textfield.layer.cornerRadius = 5
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.clear.cgColor
        
        textfield.leftViewMode = UITextFieldViewMode.always
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 15, height: 10)
        textfield.leftView = leftView
        
    }

}

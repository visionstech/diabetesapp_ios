//
//  CarePlanMedicationCell.swift
//  DiabetesApp
//
//  Created by Developer on 1/9/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class CarePlanMedicationCell: UITableViewCell {
    
    @IBOutlet weak var medicineNameTxtFld: UITextField!
    @IBOutlet weak var medImageView: UIImageView!
    @IBOutlet weak var medNameLbl: UILabel!
    @IBOutlet weak var conditionNameLbl: UILabel!
    @IBOutlet weak var dosageTxtFld: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var vwDetail: UIView!
    @IBOutlet weak var imgCarBg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mainView.layer.cornerRadius = 8
        
        // Left margins
        setleftpadding(textfield: dosageTxtFld)
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

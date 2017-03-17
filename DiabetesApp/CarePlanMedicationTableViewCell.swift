//
//  CarePlanMedicationTableViewCell.swift
//  DiabetesApp
//
//  Created by IOS4 on 29/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class CarePlanMedicationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var medImageView: UIImageView!
    @IBOutlet weak var medNameLbl: UILabel!
    
    @IBOutlet weak var medicineNameTxtFld: AutocompleteSearchTextField!
    
    @IBOutlet weak var vwDetail: UIView!
    @IBOutlet weak var imgCarBg: UIImageView!
    @IBOutlet weak var conditionNameLbl: UILabel!
    @IBOutlet weak var conditionTxtFld: UITextField!
   
    @IBOutlet weak var btnConditionDelete: UIButton!
    @IBOutlet weak var dosageTxtFld: UITextField!
    @IBOutlet weak var addMedicationView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var medImgView: UIView!
    @IBOutlet weak var medImgBtn: UIButton!
    @IBOutlet weak var medImg: UIImageView!
    
    @IBOutlet weak var medImglbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    
//    @IBOutlet weak var medNameLbl: UILabel!
//    @IBOutlet weak var medImageView: UIImageView!
//    @IBOutlet weak var mainView: UIView!
//
//    @IBOutlet weak var vwDetail: UIView!
//    
//    @IBOutlet weak var btnConditionDelete: UIButton!
//    @IBOutlet weak var medImglbl: UILabel!
//    @IBOutlet weak var medImg: UIImageView!
//    @IBOutlet weak var medImgBtn: UIButton!
//    @IBOutlet weak var medImgView: UIView!
//    @IBOutlet weak var btnAdd: UIButton!
//    @IBOutlet weak var saveBtn: UIButton!
//    @IBOutlet weak var deleteBtn: UIButton!
//    @IBOutlet weak var editBtn: UIButton!
//    @IBOutlet weak var dosageTxtFld: UITextField!
//    @IBOutlet weak var conditionTxtFld: UITextField!
//    @IBOutlet weak var conditionNameLbl: UILabel!
//    @IBOutlet weak var imgCarBg: UIImageView!
//    @IBOutlet weak var addMedicationView: UIView!
//    @IBOutlet weak var addmedicationView: UIView!
//    @IBOutlet weak var medicineNameTxtFld: AutocompleteSearchTextField!
    
   // @IBOutlet weak var medicineNameTxtFld: AutocompleteSearchTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 8
        mainView.layer.borderColor = Colors.DHAddConditionBg.cgColor
        mainView.layer.borderWidth = 1.5
     
        // Left margins
        setleftpadding(textfield: dosageTxtFld)
        if medicineNameTxtFld != nil {
            setleftpadding(textfield: medicineNameTxtFld)
            
            medicineNameTxtFld.startVisible = true
            // Set data source
            medicineNameTxtFld.filterStrings(dictMedicationName)
            
            //medicineNameTxtFld.backgroundColor = Colors.DHTabBarGreen
            medicineNameTxtFld.attributedPlaceholder = NSAttributedString(string: "Enter Medicine Name",
                                                                          attributes: [NSForegroundColorAttributeName: UIColor.white])
        }
    }

//    override func draw(_ rect: CGRect) {
//        mainView.layer.cornerRadius = 8
//        mainView.layer.borderColor = Colors.DHAddConditionBg.cgColor
//        mainView.layer.borderWidth = 1.5
//        
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setleftpadding(textfield: UITextField)
    {
      //  textfield.layer.cornerRadius = 5
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.clear.cgColor
        
        textfield.leftViewMode = UITextFieldViewMode.always
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 15, height: 10)
        textfield.leftView = leftView
        
    }

}

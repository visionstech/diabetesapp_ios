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
    @IBOutlet weak var mainPatientView: UIView!
    @IBOutlet weak var conditionLbl: UILabel!
    @IBOutlet weak var frequencyLbl: UILabel!
    @IBOutlet weak var goalLbl: UILabel!
    @IBOutlet weak var txtGoal: UITextField!
    @IBOutlet weak var btnFreq: UIButton!
    @IBOutlet weak var btnTiming: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var vwSpaceLast: UIView!
    @IBOutlet weak var costEditButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constLastViewWidth: NSLayoutConstraint!
    @IBOutlet weak var constFirstViewWidth: NSLayoutConstraint!
    @IBOutlet weak var costDeleteButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var costEditTraling: NSLayoutConstraint!
    @IBOutlet weak var costEditLeading: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let selectedUser: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
        if(selectedUser == userType.patient)
        {
            self.costEditButtonWidth.constant = 0
            self.btnEdit.setNeedsUpdateConstraints()
            
            self.constLastViewWidth.constant = 8
            self.vwSpaceLast.setNeedsUpdateConstraints()
            
            self.constFirstViewWidth.constant = 8
            
            self.costDeleteButtonWidth.constant = 0
            self.btnEdit.setNeedsUpdateConstraints()
            
        }
        self.setUI(view: mainView)
         
    }
    override func draw(_ rect: CGRect) {
        
        let maskPath : UIBezierPath
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            maskPath = UIBezierPath(roundedRect: self.conditionLbl.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
            
        }
        else
        {
            maskPath = UIBezierPath(roundedRect: self.conditionLbl.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
            
        }
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.contentView.bounds
        maskLayer.path = maskPath.cgPath
        self.conditionLbl.layer.mask = maskLayer
        
        let maskPath1 : UIBezierPath
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            maskPath1 = UIBezierPath(roundedRect: self.goalLbl.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
        }
        else
        {
            maskPath1 = UIBezierPath(roundedRect: self.goalLbl.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
        }
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.contentView.bounds
        maskLayer1.path = maskPath1.cgPath
        self.goalLbl.layer.mask = maskLayer1
        
        let maskPath2 : UIBezierPath
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            maskPath2 = UIBezierPath(roundedRect: self.txtGoal.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
        }
        else
        {
            maskPath2 = UIBezierPath(roundedRect: self.txtGoal.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
        }
        
        let maskLayer2 = CAShapeLayer()
        maskLayer2.frame = self.contentView.bounds
        maskLayer2.path = maskPath2.cgPath
        
        self.txtGoal.layer.mask = maskLayer2
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
        
    }

}

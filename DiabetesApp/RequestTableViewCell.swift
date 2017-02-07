//
//  RequestTableViewCell.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var patientTitleLabel: UILabel!
    
    @IBOutlet weak var lblDoctorEductor: UILabel!
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblEducator: UILabel!
    @IBOutlet weak var lbPatientName: UILabel!
    @IBOutlet weak var lblRequestStatus: UILabel!
    
    
  /*  @IBOutlet weak var lblRequestStatus: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblEducator: UILabel!
    @IBOutlet weak var lbPatientName: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  AddReadingCell.swift
//  DiabetesApp
//
//  Created by Developer on 2/13/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class AddReadingCell: UITableViewCell {
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var txtTiming: UITextField!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var txtGoal: UITextField!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteVW: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

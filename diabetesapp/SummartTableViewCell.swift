//
//  SummartTableViewCell.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class SummartTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTxtLbl: UILabel!
    @IBOutlet weak var ansTxtLbl: UILabel!
    
    @IBOutlet weak var vwCelllBg: UIView!
    
   // @IBOutlet weak var ansTxtLbl: UILabel!
   // @IBOutlet weak var nameTxtLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        vwCelllBg.backgroundColor = UIColor(white: 1, alpha: 0.7454489489489)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

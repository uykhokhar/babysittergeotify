//
//  DaySummaryTableViewCell.swift
//  Geotify
//
//  Created by MouseHouseApp on 5/30/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import UIKit

class DaySummaryTableViewCell: UITableViewCell {
  
  @IBOutlet weak var babySitterNameTextField: UILabel!
  @IBOutlet weak var startEndTextField: UILabel!
  @IBOutlet weak var rateTextField: UILabel!
  @IBOutlet weak var costTextField: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

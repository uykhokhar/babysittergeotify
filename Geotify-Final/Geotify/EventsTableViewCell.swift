//
//  EventsTableViewCell.swift
//  Geotify
//
//  Created by MouseHouseApp on 5/30/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var babySitterNameTextField: UILabel!
  @IBOutlet weak var eventInputTimeTextField: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

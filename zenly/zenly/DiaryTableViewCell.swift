//
//  DiaryTableViewCell.swift
//  zenly
//
//  Created by Zirong Yu on 11/24/19.
//  Copyright © 2019 Lanqing. All rights reserved.
//

import UIKit
import Firebase


class DiaryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var cell_image: UIImageView!
    @IBOutlet weak var cell_title: UILabel!
    @IBOutlet weak var cell_time: UILabel!
    
}

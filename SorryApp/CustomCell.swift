//
//  CustomCell.swift
//  Pods
//
//  Created by Joshua Hall on 9/14/16.
//
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var rank: UILabel!

    @IBOutlet weak var sns: UILabel!
    @IBOutlet weak var user: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

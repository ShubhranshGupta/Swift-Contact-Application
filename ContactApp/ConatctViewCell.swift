//
//  ConatctViewCell.swift
//  ContactApp
//
//  Created by Nuclei on 01/07/21.
//

import UIKit

class ConatctViewCell: UITableViewCell {

    @IBOutlet weak var telephonehandler: UILabel!
    @IBOutlet weak var namehandler: UILabel!
    @IBOutlet weak var imagehandler: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

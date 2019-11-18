//
//  DirectoryTableViewCell.swift
//  MEM_directory
//
//  Created by student on 10/27/19.
//  Copyright © 2019 student. All rights reserved.
//

import UIKit

class DirectoryTableViewCell: UITableViewCell {

    @IBOutlet weak var Cell_Label: UILabel!
    
    @IBOutlet weak var Cell_Image: UIImageView!
    @IBOutlet weak var Cell_Description: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

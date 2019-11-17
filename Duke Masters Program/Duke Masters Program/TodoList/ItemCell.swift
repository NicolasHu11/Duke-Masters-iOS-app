//
//  ItemCell.swift
//  ToDoList_PJ
//
//  Created by student on 11/6/19.
//  Copyright © 2019 student. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    var completed_cell : Bool!
    @IBOutlet weak var ItemName: UILabel!
    
    @IBOutlet weak var ItemDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

        override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

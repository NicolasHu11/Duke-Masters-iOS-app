//
//  CalendarCollectionViewCell.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 11/13/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    let color1  = UIColor(red: 0.9569, green: 0.9569, blue: 0.9255, alpha: 1)
    let color2 = UIColor(red: 0.0157, green: 0.1412, blue: 0.298, alpha: 1)
    let color3 = UIColor(red: 0.3922, green: 0.549, blue: 0.7686, alpha: 1)
    
    
    @IBOutlet weak var date: UILabel!
    
    func setDate(date: String, isCurrent: Bool){
        self.date.text = date
        self.date.textColor = isCurrent ? color3 : color2
    }
    
    func setShape(width: CGFloat, height: CGFloat){
        // Set a circular item cell
        let shape = CGRect(x: 5.0, y: (height/2.0 - width/2.0 + 5.0), width: width - 10.0, height: width - 10.0)
        //print(shape)
        self.date.frame = shape // Set the position of label
        let path = UIBezierPath(ovalIn: shape)
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
        self.backgroundColor = calendarCellColor
    }
}


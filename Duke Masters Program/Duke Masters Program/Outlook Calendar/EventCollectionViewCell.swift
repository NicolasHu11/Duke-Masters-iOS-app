//
//  EventCollectionViewCell.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 11/22/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit

// MARK:  The Collection Cell for Events
class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var location: UILabel!

    func configCell(from: String, to: String, subject: String, body: String? = nil, location: String? = nil){
        self.startTime.text = self.extractTime(dateTime: from)
        self.endTime.text = self.extractTime(dateTime: to)
        self.subject.text = subject
        self.location.text = (location == nil) ? "" : location
        //self.body.text = (body == nil) ? "" : body
        self.body.text = ""
        // for debug
        //print(body)
    }
    
    func extractTime(dateTime: String) -> String{
        print(dateTime)
        let start = dateTime.index(after: dateTime.index(of: "T") ?? dateTime.startIndex)
        let subString = String(dateTime[start..<dateTime.index(start,offsetBy: 8)])
        return subString
    }
    
    func setTextColor(_ color: UIColor){
        self.startTime.textColor = color
        self.endTime.textColor = color
        self.subject.textColor = color
        self.body.textColor = color
        self.location.textColor = color
    }
    
    func setShape(width: CGFloat, height: CGFloat){
        // Set the boundary to be a rounded rectangle
        let shape = CGRect(x: 0, y: 0, width: width, height: height)
        let path = UIBezierPath(roundedRect: shape, cornerRadius: 10.00)
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

//
//  ChatMessageCell.swift
//  Duke Masters Program
//
//  Created by student on 11/14/19.
//  Copyright © 2019 Duke University. All rights reserved.
//


import UIKit

class ChatMessageCell: UICollectionViewCell {
    // Textview Display Name and Date
    let TextView : UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE"
        tv.font = .systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = hexStringToUIColor(hex: randomcolor())
        return tv
    }()
    let MessageView : UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE"
        tv.font = .systemFont(ofSize: 18)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = hexStringToUIColor(hex: randomcolor())
        return tv
    }()
    override init(frame: CGRect){
        super.init(frame: frame)
        self.contentView.addSubview(TextView)
        self.contentView.addSubview(MessageView)
//        addSubview(ImageView)
        prepare()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unimplemented")
    }
    func prepare(){
       
//        self.contentView.backgroundColor = hexStringToUIColor(hex: randomcolor())
        // set shadow and broder
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
//        self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        self.contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        self.contentView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        // Name and Date TextView display
        TextView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        
        TextView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
        TextView.heightAnchor.constraint(equalToConstant: 30).isActive = true
//                TextView.backgroundColor = hexStringToUIColor(hex: randomcolor())
        TextView.isEditable = false
//        TextView.isScrollEnabled = false
        
        // Message Textview display
        
        MessageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        MessageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 30).isActive = true
        MessageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        MessageView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
        MessageView.isEditable = false
        
    }
    
    
}

//MARK: Change color for next version

func randomcolor()-> String{
    let white = "edeff7"
    let yellow = "8595c5"
    let green = "b9dec3"
    let gray = "c2deb9"
    let colors = [white,yellow, green, gray]
    return colors.randomElement()!
}
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

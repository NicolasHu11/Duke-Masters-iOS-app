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
        tv.backgroundColor = .gray
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    let MessageView : UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE"
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .gray
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(TextView)
        addSubview(MessageView)
        prepare()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unimplemented")
    }
    func prepare(){
        self.contentView.backgroundColor = .white
        // set shadow and broder
//        self.contentView.layer.cornerRadius = 5.0
//        self.contentView.layer.borderWidth = 1.0
//        self.contentView.layer.borderColor = UIColor.clear.cgColor
//        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 5.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        // Name and Date TextView display
                    TextView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        //        TextView.rightAnchor.constraint(equaltoConstant: 30).isActive = true
                TextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

                TextView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
                TextView.heightAnchor.constraint(equalToConstant: 30).isActive = true
                TextView.backgroundColor = .blue
                TextView.isEditable = false
        
        // Message Textview display
                MessageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        //        TextView.rightAnchor.constraint(equaltoConstant: 30).isActive = true
        MessageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        MessageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant:  50).isActive = true
                MessageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        MessageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                MessageView.backgroundColor = .gray
                MessageView.isEditable = false
    }
}

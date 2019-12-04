//
//  User.swift
//  Duke Masters Program
//
//  Created by student on 11/9/19.
//  Copyright © 2019 Duke University. All rights reserved.
//


import UIKit

//The class is to save messages content and the info of sender

class User: NSObject {
    var name: String?
    var email: String?
    var message:String?
    var date: String?
    //var profileImageUrl: String?
    override init(){
        self.name = ""
        self.email = ""
        self.message = ""
        self.date = ""
    }
    init(dictionary: [String: AnyObject]) {
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.message = dictionary["text"] as? String
        self.date = dictionary["time"] as? String
        //self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}

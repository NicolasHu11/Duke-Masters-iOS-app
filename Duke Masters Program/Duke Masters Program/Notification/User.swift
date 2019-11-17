//
//  User.swift
//  gameofchats
//
//  Created by Brian Voong on 6/29/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

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

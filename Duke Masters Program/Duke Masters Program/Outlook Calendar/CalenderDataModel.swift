//
//  CalenderDataModel.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 11/12/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit
import MSAL
import MSGraphMSALAuthProvider
import MSGraphClientSDK
import MSGraphClientModels

class eventPreperation{
    
    // properties: required
    var body = ""
    var subject = ""
    var start = DateTimeTimeZone()
    var end = DateTimeTimeZone()
    
    // properties: optional
    var isReminderOn: Bool?
    var reminderMinutesBeforeStart: Int?
    var bodyPreview: String?
    var location: Location?
    var recurrence: PatternedRecurrence?
    
    
    //initializer
    init(){
    //reserved for later modification
    }
    
    func eventToJSON() -> Data?{
        
        // ---------- PREPARING THE OBJECT TO BE CONVERTED ----------
        // use dictionary to format data
        var json: Dictionary<String, Any>
        json = [:]
        // required field
        json["subject"] = self.subject
        json["body"] = ["contentType":"HTML", "content": self.body]
        json["start"] = ["dateTime": self.start.dateTime, "timeZone": self.start.timeZone]
        json["end"] = ["dateTime": self.end.dateTime, "timeZone": self.end.timeZone]
        // optional field
        if self.bodyPreview != nil{
            json["bodyPreview"] = self.bodyPreview
        }
        if self.location != nil{
            json["location"] = ["displayName": self.location?.displayName, "locationType": self.location?.locationType, "uniqueId": self.location?.uniqueId, "uniqueIdType": self.location?.uniqueIdType]
        }
        if self.recurrence != nil{
            let temp = self.recurrence!
            json["recurrence"] = [
                ["pattern": ["type": temp.pattern.type, "interval": temp.pattern.interval, "daysOfWeek": temp.pattern.daysOfWeek]],
                ["range":["type": temp.range.type, "startDate": temp.range.startDate, "endDate": temp.range.endDate]]
            ]
        }
        if self.isReminderOn != nil{
            json["isReminderOn"] = self.isReminderOn
        }
        if self.reminderMinutesBeforeStart != nil{
            json["reminderMinutesBeforeStart"] = self.reminderMinutesBeforeStart
        }
        // ---------- CONVERT TO JSON DATA ----------
        var jsonData = Data()
        // valid objeect?
        if(!JSONSerialization.isValidJSONObject(json)){
            print("Error in preparing the dictionary: CalendarDataModel-eventPreperation-eventToJSON")
            return nil
        }
        // convert
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted){
            if let printData = String(data: data, encoding: .utf8){
                print(printData)
            }
            jsonData = data
        }else{
            print("Error in preparing the JSON data: CalendarDataModel-eventPreperation-eventToJSON")
            return nil
        }
        
        // ---------- RETURN JSONDATA ----------
        return jsonData
    }
}

extension eventPreperation{
    // some structs that will be used
    struct DateTimeTimeZone {
        var dateTime: String = "2020-01-01T00:00:00"
        var timeZone: String = "Pacific Standard Time"
    }
    struct Location {
        var displayName = ""
        var locationType = "default"
        var uniqueId = ""
        var uniqueIdType = ""
    }
    struct Pattern {
        var type = "weekly"
        var interval = 1
        var daysOfWeek = ["Monday"]
    }
    struct Range {
        var type = "endDate"
        var startDate = "2019-12-01"
        var endDate = "2020-01-01"
    }
    struct PatternedRecurrence{
        var pattern = Pattern()
        var range = Range()
    }
}


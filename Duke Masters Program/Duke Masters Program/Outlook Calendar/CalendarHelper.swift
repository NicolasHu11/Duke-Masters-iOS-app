//
//  CalendarHelper.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 11/13/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit

// Dictionary between month number and month name
let monthLiteral = [1:"January",
                    2:"February",
                    3:"March",
                    4:"April",
                    5:"May",
                    6:"June",
                    7:"July",
                    8:"August",
                    9:"Sptember",
                    10:"October",
                    11: "November",
                    12:"December"]
let weekdayLiteral = [1:"Mon.", 2:"Tues.", 3:"Wed.", 4:"Thur.", 5:"Fri.", 6:"Sat.", 7:"Sun."]

// For a given date, return which weekday it is
// Sun: 0   Mon: 1  Tue: 2  Wen: 3  Thu: 4  Fri: 5  Sat: 6
func configWeekDay(year: Int, month: Int, day: Int) -> Int{
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let monthString = (month < 10) ? "0"+"\(month)" : "\(month)"
    let dayString = (day < 10) ? "0"+"\(day)" : "\(day)"
    let date = dateFormat.date(from: "\(year)" + "-" + monthString + "-" + dayString + " 00:01:00")
    let Interval = Int(date!.timeIntervalSince1970) + NSTimeZone().secondsFromGMT
    let days = Int(Interval/86400)
    let weekday = ((days+4)%7 + 7)%7
    print(weekday)
    return weekday
}

// For a given date, return how many days in that month
func monthDays(year: Int, month: Int) -> Int{
    switch month {
    case 2:
        return (year%4==0) ? 29 : 28
    case 1,3,5,7,8,10,12:
        return 31
    default:
        return 30
    }
}

// For a given month, return the start time and end time
func startEndLiteral(year: Int, month: Int) -> (String, String){
    let monthDate = monthDays(year: year, month: month)
    let start = "\(year)" + "-" + ((month < 10) ? "0\(month)" : "\(month)") + "-01"//T00:00"
    let end = "\(year)" + "-" + ((month < 10) ? "0\(month)" : "\(month)") + "-" + "\(monthDate)" //+ "T23:59"
    return (start, end)
}

// Display color related
let redBrighter = [UIColor(red: 0.9098, green: 0.1255, blue: 0.2, alpha: 1),
                   UIColor(red: 0.9176, green: 0.1961, blue: 0.2667, alpha: 1),
                   UIColor(red: 0.9255, green: 0.2667, blue: 0.3294, alpha: 1),
                   UIColor(red: 0.9333, green: 0.3373, blue: 0.3922, alpha: 1),
                   UIColor(red: 0.9412, green: 0.4078, blue: 0.4588, alpha: 1),
                   UIColor(red: 0.9451, green: 0.4745, blue: 0.5216, alpha: 1),
                   UIColor(red: 0.9529, green: 0.5451, blue: 0.5843, alpha: 1)]
let redDarker = [UIColor(red: 0.8627, green: 0.3294, blue: 0.3804, alpha: 1),
                 UIColor(red: 0.8314, green: 0.3608, blue: 0.4039, alpha: 1),
                 UIColor(red: 0.8000, green: 0.3922, blue: 0.4314, alpha: 1),
                 UIColor(red: 0.7686, green: 0.4235, blue: 0.4549, alpha: 1),
                 UIColor(red: 0.7373, green: 0.4549, blue: 0.4784, alpha: 1),
                 UIColor(red: 0.7098, green: 0.4824, blue: 0.5059, alpha: 1),
                 UIColor(red: 0.6784, green: 0.5137, blue: 0.5394, alpha: 1)]

let mainBlue  = UIColor(red: 0.0000, green: 0.3529, blue: 0.6549, alpha: 1)
let darkerBlue = [UIColor(red: 0.0235, green: 0.3490, blue: 0.6314, alpha: 0.5),
                  UIColor(red: 0.0051, green: 0.3490, blue: 0.6039, alpha: 0.5),
                  UIColor(red: 0.0745, green: 0.3451, blue: 0.5804, alpha: 0.5),
                  UIColor(red: 0.0102, green: 0.3451, blue: 0.5529, alpha: 0.5),
                  UIColor(red: 0.1255, green: 0.3412, blue: 0.5394, alpha: 0.5),
                  UIColor(red: 0.1529, green: 0.3412, blue: 0.5020, alpha: 0.5),
                  UIColor(red: 0.1765, green: 0.3373, blue: 0.4784, alpha: 0.5),
                  UIColor(red: 0.2000, green: 0.3373, blue: 0.4549, alpha: 0.5),
                  UIColor(red: 0.2275, green: 0.3373, blue: 0.4275, alpha: 0.5),
                  UIColor(red: 0.2510, green: 0.3333, blue: 0.4039, alpha: 0.5),
                  UIColor(red: 0.2784, green: 0.3333, blue: 0.3765, alpha: 0.5)]
let brighterBlue = [UIColor(red: 0.1569, green: 0.4235, blue: 0.6745, alpha: 0.5),
                    UIColor(red: 0.2667, green: 0.4863, blue: 0.7059, alpha: 0.5),
                    UIColor(red: 0.3294, green: 0.5176, blue: 0.7373, alpha: 0.5),
                    UIColor(red: 0.4745, green: 0.6118, blue: 0.7686, alpha: 0.5),
                    UIColor(red: 0.4000, green: 0.5804, blue: 0.7373, alpha: 0.5),
                    UIColor(red: 0.5961, green: 0.7059, blue: 0.8000, alpha: 0.5),
                    UIColor(red: 0.6431, green: 0.7373, blue: 0.8000, alpha: 0.5),
                    UIColor(red: 0.7373, green: 0.8157, blue: 0.8314, alpha: 0.5),
                    UIColor(red: 0.8314, green: 0.8627, blue: 0.8588, alpha: 0.5),
                    UIColor(red: 0.8941, green: 0.9255, blue: 0.8627, alpha: 0.5),
                    UIColor(red: 0.9882, green: 0.9843, blue: 0.8941, alpha: 0.5)]





let calendarCellColor = UIColor(red: 0.9569, green: 0.9569, blue: 0.9255, alpha: 1)
//let calendarCellSelected = UIColor(red: 0.9255, green: 0.3686, blue: 0.2667, alpha: 1)
//let calendarCellToday = UIColor(red: 0.7451, green: 0.8353, blue: 0.8863, alpha: 0.1)

let calendarBack = [UIColor(red: 1.0000, green: 0.9922, blue: 0.8941, alpha: 0.5), UIColor(red: 0.0000, green: 0.3529, blue: 0.6549, alpha: 0.5)]

//let calendarBack = [UIColor(red: 0.6784, green: 0.3255, blue: 0.5373, alpha: 0.5), UIColor(red: 0.2353, green: 0.0627, blue: 0.3255, alpha: 0.5)]



let calendarCellSelected = UIColor(red: 0.2510, green: 0.3333, blue: 0.4039, alpha: 0.1)
let calendarCellToday = calendarBack[0]

let upcomingTextColor = UIColor(red: 1.0000, green: 0.9922, blue: 0.8941, alpha: 1)
let passedTextColor = UIColor(red: 0.0000, green: 0.3529, blue: 0.6549, alpha: 0.8)

let assignmentTextColor = UIColor(red: 1.0000, green: 0.9765, blue: 0.2980, alpha: 0.8)

func extractTime(dateTime: String) -> String{
    print(dateTime)
    let start = dateTime.index(after: dateTime.index(of: "T") ?? dateTime.startIndex)
    let subString = String(dateTime[start..<dateTime.index(start,offsetBy: 8)])
    return subString
}

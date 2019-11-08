//
//  Dataprocess.swift
//  ToDoList_PJ
//
//  Created by student on 11/6/19.
//  Copyright © 2019 student. All rights reserved.
//

import Foundation
class Checklistitem: NSObject, Codable{
    var itemname: String!
    var date: String!
    var Description : [String]!
    var completed: Bool!

static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Checklisttest1")
    init(itemname : String, date : String, Description : [String], completed : Bool) {
        self.itemname = itemname
        self.date = date
        self.Description = Description
        self.completed = false
    }
static func encodeChecklist(_ item: [Checklistitem])-> Bool{
    print("current in encode part")
            var outputData = Data()
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(item) {
                if let json = String(data: encoded, encoding: .utf8) {
                    print(json)
                    outputData = encoded
                }
                else { return false }

                do {
                    try outputData.write(to: Checklistitem.ArchiveURL)
                } catch let error as NSError {
                    print (error)
                    return false
                }
                return true
            }
            else { return false }
}
static func loadChecklist() -> [Checklistitem]? {
        let decoder = JSONDecoder()
        var loadedData = [Checklistitem]()
        let tempData: Data

        do {
            tempData = try Data(contentsOf: ArchiveURL)
            print("tempdataloaded")
        } catch let error as NSError {
            print(error)
            return nil
        }
        if let decoded = try? decoder.decode([Checklistitem].self, from: tempData) {
//            print(decoded[0].firstName)
            loadedData = decoded
        }
        return loadedData
    }
}
var test1 = Checklistitem(itemname: "Begin using your Duke email", date: "Immediately", Description: ["Once you have activated your NetID, you will have access to the online Duke email system. Visit this site to learn how to access your Duke email account and to answer any questions you may have. Once you have access to your Duke email, begin the practice of checking and using this address. Your Duke email address will become the primary source for all individual communications from the program. Be sure to check this account daily once you have access.",
"This become super important when other offices are sending you information this summer. While our office may have access to the email you used in your application (gmail, yahoo, etc.) other offices do not. So very important information from the I house or Student Health are ONLY sent to your duke email. Save yourself the headache and begin using this email as soon as you have access. Trust us!",
"The website address for your Duke email is: outlook.com/duke.edu",
"If you have a particularly long name, you can use a short 'alias' name. For example Ian Turnage-Butterbagh's email is ian.tb@duke.edu. instructions on how to do this are posted here.",
"Need more directions? Look here!"], completed : false)
 var test2 = Checklistitem(itemname: "Begin using your Duke outlook calendar", date: "Immediately", Description: ["Once you have activated your NetID and accessed your Duke email, you now have access to your Duke Outlook calendar! This is how you will stay organized and let people know your availability for meetings. Once Fall classes begin, if not beforehand, your schedule will become full. When arranging a meeting, use your Duke outlook calendar for meeting requests and appointments. You can make appointments private, so people can see you are unavailable, but not the details of the appointment.",
 "If you aren't familiar with the basics, start here:",
 "•    Basics!",
 "•    Create an appointment",
 "•    Create a meeting",
 "•    Calendar views",
 "•    Use the scheduling assistant",
 "•    Share your calendar"], completed : false)
var test3 = Checklistitem(itemname: "Submit Immunization Forms", date: "15-Dec", Description: ["The State of North Carolina requires all students to satisfy immunization requirements – both domestic and international.  Class registration will be cancelled if you are not in compliance with immunization requirements and you may be withdrawn from class if you do not remain compliant during your time at Duke. You will receive messages regarding your immunization compliance via your Student Health Gateway which can be accessed on the Student Health Website. Please refer to the Immunization FAQs for more information.",
"There are several steps to submitting your immunizations. Please review this page and follow the steps. The immunization form is due on December 15.",
"Points to note:",
"•    You are a Graduate/Professional student",
"•    We will have a set time during orientation to get your TB testing.",
"If you have any questions on immunizations, please contact Student Health, Immunization Compliance Coordinator at immunizations@duke.edu."], completed: false)
var test4 = Checklistitem(itemname: "Secure Housing in Durham", date: "Early December", Description: ["You may be wondering, where should I live? The majority of our students live off of Lasalle Drive, which is both walking and easy bus distance to the Engineering School. There are other cool options downtown (if you like to go out) and in South Durham (quieter and better for families) as well. Here is a list of some popular places for our students. A small word of advice: just because a place is inexpensive or because many people live there doesn't always mean it's the best place for you! Make sure you research and consider things like apartment complex safety and amenities as well.",
"Additional housing resources you may find helpful:",
"•    Join the Pratt Master Housing Listserv to connect with others searching for housing in Durham",
"o    Log in with your NetID at https://lists.duke.edu/sympa then search for 'prattmasterhousing' and subscribe",
"•    Popular Housing Options",
"•    Duke’s International House (Extensive list of information on local apartment complexes near Duke Campus.)",
"•    Near Duke",
"•    DukeList (requires NetID to log in)",
"•    Housing options that are near free bus service",
"Please note: The MEM program nor the Pratt School of Engineering have any affiliation with the above housing options." ], completed: false)
var test5 = Checklistitem(itemname: "Finalize your Tuition Payment Type", date: "End of Drop/Add (January 22) but January 7 is ideal", Description: ["Information on pay-by-term vs pay-by-credit is posted on the MEM Sakai site under Academic Services>When is my bill due?"], completed: false)
var test6 = Checklistitem(itemname: "Pay your Bursar Bill", date: "7-Jan", Description: ["Spring 2020 charges (tuition and fees) will post to your DukeHub account on December 2 and will be due on January 7, 2020.",
"If you make changes to your course enrollment, your bill may change between December 2 and January7. For example, if you're enrolled in four courses but decide to drop one of those courses during the Drop/Add Period (the first two weeks of each semester) AND you change your tuition payment option to pay-per-credit, your tuition would decrease. If you had already paid your tuition bill, you will receive a refund for the amount owed to you.",
"Keep in mind:",
"•    You must finalize your schedule by the end of drop/add",
"•    If you would like to pay-by-credit, you must request this option by emailing Kelsey Liddle (Kelsey.Liddle@duke.edu)",
"•    If you pay your tutition and then change your enrollment to result in a refund, you will receive the refund to our account (as long as all changes were settled by the drop/add deadline)",
"For more information, please check the Academics Services tab on the left or the Bursar's website here: http://finance.duke.edu/bursar/"
], completed: false)
var test7 = Checklistitem(itemname: "Read the Duke Community Standard", date: "January 8", Description: ["Course registration information is posted to MEMP Sakai under the Academic Services tab > registration"], completed: false)
var firstyear_list = [test1,test2,test3,test4, test5, test6, test7]

//
//  outlookCommunication.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 11/20/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit
import MSAL
import MSGraphMSALAuthProvider
import MSGraphClientSDK
import MSGraphClientModels

class outlookCommunication {
    // Implement singleton pattern
    static let instance = outlookCommunication()
    
    //MSAL related
    private let appId = "6446a4e7-b3db-4d57-9c8e-83bdcc796580"
    let graphURL = "https://graph.microsoft.com/v1.0/me/"
    //API permissions
    let graphScope: [String] = ["https://graph.microsoft.com/user.read", "https://graph.microsoft.com/Calendars.Read", "https://graph.microsoft.com/Calendars.ReadWrite"]
    //Login webpage
    let calendarAuthority = "https://login.microsoftonline.com/common"
    
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?

    //Graph related
    var client: MSHTTPClient?
    var graphevents: [MSGraphEvent] = []
    var eventDict = [String:[MSGraphEvent]]()   //Dictionary with key: date(yyyy-MM-dd), value: [MSGraphEvent]
    var loadedMonth = Set<String>()             //Array with loaded monthes
    //Reserved for later
    //Dictionary with key: calendar name/value:a dictionary with key: date(yyyy-MM-dd), value: [MSGraphEvent]
    var calendarEventDict = [String:[String:[MSGraphEvent]]]()
    
    //夭寿啦！
    var calendarDict = [String:Any]()
    var calendarRequestCompleted = false
    
    //Initialization
    init(){
        // Just reserved for the protocal
        print("Initializing the outlookCommunication")
    }
}
// MARK: Initialization
extension outlookCommunication{
    
    // Initialize MSAL
    func initMSAL(parentViewController: UIViewController) throws {
        // authoruty URL (login)
        guard let authorityURL = URL(string: self.calendarAuthority) else {
            print("invalid url!")
            return
        }
        let authority = try MSALAADAuthority(url: authorityURL)
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: appId, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.webViewParamaters = MSALWebviewParameters(parentViewController: parentViewController)
    }
    
    // Initialize Graph
    func graphInit(){
        print("In Graph Initialization!")
        // create the authenticationProvider
        // get a MSALPublicClientApplication, here use the applicationContext
        let authProviderOptions = MSALAuthenticationProviderOptions(scopes: self.graphScope)
        let authenticationProvider = MSALAuthenticationProvider(publicClientApplication: self.applicationContext, andOptions: authProviderOptions)
        // create the client with the authenticationProvider
        self.client = MSClientFactory.createHTTPClient(with: authenticationProvider)
        print("Graph initialization completed!")
    }
    
    
}

// MARK: Event Related
extension outlookCommunication{
    func graphEvent(){
            print("In graphEvent!")
            let select = "$select=subject,organizer,start,end"
            // Sort results by when they were created, newest first
            let orderBy = "$orderby=createdDateTime+DESC"
            let eventsRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/events?\(select)&\(orderBy)")!)
            
            let eventsDataTask = MSURLSessionDataTask(request: eventsRequest, client: self.client, completion: {
                (data: Data?, response: URLResponse?, graphError: Error?) in
                guard let eventsData = data, graphError == nil else {
                    return
                }
                do {
                    print("Deserializing!")
                    // Deserialize response as events collection
                    let eventsCollection = try MSCollection(data: eventsData)
                    eventsCollection.value.forEach({
                        (rawEvent: Any) in
                        // Convert JSON to a dictionary
                        guard let eventDict = rawEvent as? [String: Any] else {
                            return
                        }
                        // Deserialize event from the dictionary
                        let event = MSGraphEvent(dictionary: eventDict)!
                        self.graphevents.append(event)
                    })
                } catch let error{
                    // ~ FOR DEBUGGING!
                    print("In outlookCommunication (getting graph events)")
                    print("graphEvent() error: \(error)")
                }
                print("Got events from outlook calendar successfully!")
            })
            // Execute the request
            eventsDataTask?.execute()
        }
    
    func getEvents(inCalendar: String, startFrom: String, to: String){
        let calendarID = self.calendarDict[inCalendar] as! String
        print(inCalendar)
        print(startFrom)
        loadedMonth.insert(String(startFrom.prefix(7)))
        print(loadedMonth)
       // let requestLiteral = MSGraphBaseURL + "/me/events?$top=200&$filter=start/dateTime ge '\(startFrom)' and start/dateTime le '\(to)'" + "&$select=subject,body,start,end,location" + "&$orderBy=start/dateTime+ASC"
        let requestLiteral = MSGraphBaseURL + "/me/calendars/\(calendarID)/events?$top=200&$filter=start/dateTime ge '\(startFrom)' and start/dateTime le '\(to)'" + "&$select=subject,body,start,end,location" + "&$orderBy=start/dateTime+ASC"
        let test = requestLiteral.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let eventsRequest = NSMutableURLRequest(url: URL(string: test!)!)
       // let eventsRequest = NSMutableURLRequest(url: URL(string: requestLiteral)!)
        eventsRequest.httpMethod = "GET"
        eventsRequest.setValue("outlook.timezone=\"Eastern Standard Time\"", forHTTPHeaderField: "Prefer")
        let eventsDataTask = MSURLSessionDataTask(request: eventsRequest, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let eventsData = data, graphError == nil else {
                return
            }
            do {
                print("Deserializing!")
                // Deserialize response as events collection
                let eventsCollection = try MSCollection(data: eventsData)
                eventsCollection.value.forEach({
                    (rawEvent: Any) in
                    // Convert JSON to a dictionary
                    guard let eventDict = rawEvent as? [String: Any] else {
                        return
                    }
                    // Deserialize event from the dictionary
                    let event = MSGraphEvent(dictionary: eventDict)!
                    let startDate = String((event.start?.dateTime.prefix(10))!)
                    print(startDate)
                    // MARK: Need later modification
//                    if inCalendar == "Calendar"{
//                        if self.eventDict.keys.contains(startDate){
//                            self.eventDict[startDate]?.append(event)
//                        }else{
//                            self.eventDict[startDate] = [event]
//                        }
//                    }
                    //else{
                        //print("In sakai")
                        if self.eventDict.keys.contains(startDate){
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            let eventStartDate = dateFormatter.date(from: String(event.start!.dateTime.prefix(19)))
                            let ran = (self.eventDict[startDate]?.count)!
                            for index in 0..<ran {
                                let start = self.eventDict[startDate]![index].start?.dateTime
                                let startDa = dateFormatter.date(from: String(start!.prefix(19)))
                                //print("calendar: \(String(describing: startDa))")
                                //print("sakai: \(String(describing: eventStartDate))")
                                if startDa?.compare(eventStartDate!) == .orderedDescending {
                                    //print("calendar里的比sakai里的迟，把sakai里的插进去")
                                    self.eventDict[startDate]?.insert(event, at: index)
                                    break
                                }
                                if index == ran - 1{
                                    self.eventDict[startDate]?.append(event)
                                }
                            }
                        }else{
                            self.eventDict[startDate] = [event]
                        }
                    //}
                })
            } catch let error{
                // ~ FOR DEBUGGING!
                print("In outlookCommunication (getting graph events)")
                print("graphEvent() error: \(error)")
            }
            print("Got events from outlook calendar successfully!")
        })
        // Execute the request
        eventsDataTask?.execute()
    }

    
    func createEvent(start: String, end: String, subject: String, body: String = ""){
        let urlRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/events")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("outlook.timezone=\"UTC-05:00\"", forHTTPHeaderField: "Prefer")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare event
        let eventPrep = eventPreperation()
        eventPrep.start.dateTime = start
        eventPrep.end.dateTime = end
        eventPrep.subject = subject
        eventPrep.body = body
            
        let eventData = eventPrep.eventToJSON()
        
        // Set httpBody
        urlRequest.httpBody = eventData
        
        let dataTask = MSURLSessionDataTask(request: urlRequest, client: self.client, completion: {
            (data: Data?, response: URLResponse?, error) in
            guard let backData = data, error == nil else{
                if error != nil{
                    print("error occurs")
                    //print("error in adding an event to outlook calendar: \(error)")
                }
                return
            }
            print("data: \(backData)")
            if response != nil{
                //print("response:")
                //print("\(response!)")
                let temp = response as! HTTPURLResponse
                if temp.statusCode == 201{
                    print("Added Event Successfully: " + subject)
                }
            }
        })
        dataTask?.execute()
    }
}

// MARK: Calendar Related
extension outlookCommunication{
    // Get calendars for current user
    func getUserCalendars() -> [String : Any]{
        //var calendarDict = [String:Any]()
        print("Trying to get current user's calendars")
        
        let getCalendarsRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/calendars")!)
        getCalendarsRequest.httpMethod = "GET"
        
        let getCalendarsDataTask = MSURLSessionDataTask(request: getCalendarsRequest, client: self.client, completion: {
                (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let calendarData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Any] else{
                print("Couldn't deserialize result JSON")
                return
            }
            let calendars = calendarData["value"] as! [[String: Any]]
            for calendar in calendars {
                let tempName = calendar["name"] as! String
                self.calendarDict[tempName] = calendar["id"]
            }
            print(self.calendarDict)
            print("Successfully got current user's calendars")
            justAtry()
            self.calendarRequestCompleted = true
            // return calendarDict
        })
        
        // Execute the request
        print("executing......")
        getCalendarsDataTask?.execute()
        print("Successfully excuted!")
        //print("calendarDict contains: \(calendarDict.count)" )
        return calendarDict
    }

    // Create a calendar for current user
    func createCalendar(name: String) {
        print("Trying to create a calendar")
        let urlRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/calendars")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let calendar = MSGraphCalendar()
        calendar.name = name
        do {
            let calendarData = try calendar.getSerializedData()
            urlRequest.httpBody = calendarData
        } catch let error as NSError {
            print("Error in serializing calendar date: \(error)")
        }
        
        let dataTask = MSURLSessionDataTask(request: urlRequest, client: self.client, completion: {
                    (data: Data?, response: URLResponse?, error) in
                    guard let backData = data, error == nil else{
                        if error != nil{
                            print("error occurs")
                        }
                        return
                    }
                    print("data: \(backData)")
                    if response != nil{
                        let temp = response as! HTTPURLResponse
                        if temp.statusCode == 201{
                            print("Added Calendar Successfully: " + name)
                            guard let returnData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Any] else{
                                print("Couldn't deserialize result JSON")
                                return
                            }
                        print(returnData)
                            //let calendar = returnData["value"] as! [[String: Any]]
                        self.calendarDict[name] = returnData["id"]
                        }else{
                            print("Creating calendar failed")
                            print(temp.statusCode)
                        }
                    }
                })
        dataTask?.execute()
    }
}

// MARK: Acquiring and using token
extension outlookCommunication{
    
    // Acquire token interactively (when there's no user signed in)
    // MARK: THIS FUNCTION CAN ONLY BE CALLED WHEN THERE'S A VIEW! (in viewDidAppear())
    func acquireTokenInteractively(){
        print("acquireTokenInteractively")
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: self.graphScope, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount;

        applicationContext.acquireToken(with: parameters){(result, error) in

            if let error = error{
               print("Could not acquire token: \(error)")
                return
            }

            guard let result = result else{
                print("Could not acquire token: No result returned")
                return
            }

            self.accessToken = result.accessToken
            //print("Access token is \(self.accessToken)")
            self.getContentWithToken()
        }

    }
    
    // Acquire token silently (when someone has signed in before and no more actions are needed)
    func acquireTokenSilently(_ account : MSALAccount!) {
        print("acquireTokenSilently")
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: self.graphScope, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                print("Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                print("Could not acquire token: No result returned")
                return
            }
            self.accessToken = result.accessToken
            //print("Refreshed Access token is \(self.accessToken)")
            //self.getContentWithToken()
        }
    }
    
    func getContentWithToken() {
        // Specify the Graph API endpoint
        let url = URL(string: graphURL)
        var request = URLRequest(url: url!)
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Couldn't get graph result: \(error)")
                return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                print("Couldn't deserialize result JSON")
                return
            }
            //print("Result from Graph: \(result)")
            
            }.resume()
    }
}

extension outlookCommunication{
    func currentAccount() -> MSALAccount? {
        
        guard let applicationContext = self.applicationContext else { return nil }
        // We retrieve our current account by getting the first account from cache
        // In multi-account applications, account should be retrieved by home account identifier or username instead
        do {
            let cachedAccounts = try applicationContext.allAccounts()
            if !cachedAccounts.isEmpty {
                return cachedAccounts.first
            }
        } catch let error as NSError {
            print("Didn't find any accounts in cache: \(error)")
        }
        return nil
        
    }
}


func justAtry(){
    print("脑洞开上天系列!")
}




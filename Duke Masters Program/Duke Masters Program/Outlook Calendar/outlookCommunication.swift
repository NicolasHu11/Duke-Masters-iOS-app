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
import MSGraphClientModels

class outlookCommunication {
    
    // Calendar View Controller
    var CalendarViewController: CalendarDisp? = nil

    // Init loaded flag
    var loadedFlag = false
    var tokenFlag = true        // Assume that currently there's a signed account
    // Implement singleton pattern
    static let instance = outlookCommunication()
    
    // ---------- Authentication Related ----------
    // APP ID, that is assigned by Microsoft Azure
    private let appId = "6446a4e7-b3db-4d57-9c8e-83bdcc796580"
    /**If to use Duke Mail:
     substitute corresponding properties  to following code and require the Administrator's permission to user.read and Calendars.ReadWrite **/
    /*
     // The APP ID that is assigned by Microsoft Azure under Duke Directory
     private let appId = "2b8de4b8-bf28-4d4a-95d2-8f58a1119085"
     //[cb72c54e-4a31-4d9e-b14a-1ea36dfac94c] is the tenant ID for Duke, if to use the School Account
     let calendarAuthority = "https://login.microsoftonline.com/cb72c54e-4a31-4d9e-b14a-1ea36dfac94c"
    */
    // Tenant ID for Duke, that is same for all apps registered under Duke Directory in Mocrosoft Azure
    // private let tenantId = "cb72c54e-4a31-4d9e-b14a-1ea36dfac94c"
    // App permissions
    let graphScope: [String] = ["https://graph.microsoft.com/user.read", "https://graph.microsoft.com/Calendars.ReadWrite"]
    // API for Microsoft Graph
    let graphURL = "https://graph.microsoft.com/v1.0/me/"
    // The authentication endpoint
    let calendarAuthority = "https://login.microsoftonline.com/common"
    // A variable used to stroe the returned token, will be assigned later
    var accessToken = String()
    // MARK: 可能要改的！
    // A variable to describe the client application, will be configured later
    var applicationContext : MSALPublicClientApplication?
    // A variable used to describe the webpage that will be used for Login (i.e. acquire token interactively)
    var webViewParamaters : MSALWebviewParameters?
    // (Graph Related)The client that will be used to send requests to Microsoft Graph, will be configured later
    var client: MSHTTPClient?
    
    // ---------- Returned Data Related ----------
    // Array with loaded monthes: yyyy-MM
    // -Used to record monthes with loaded data and prevent repeating loading
    var loadedMonth = Set<String>()
    // Dictionary with key: date(yyyy-MM-dd), value: [MSGraphEvent]
    // -Used to store the calendar events returned by Microsoft Graph
    var eventDict = [String:[MSGraphEvent]]()
    //Dictionary with key: calendar name/value:a dictionary with key: date(yyyy-MM-dd), value: [MSGraphEvent]
    var calendarEventDict = [String:[String:[MSGraphEvent]]]()
    var graphevents: [MSGraphEvent] = []
    //夭寿啦！
    var calendarDict = [String:Any]()
    var calendarRequestCompleted = false
    
    //Initialization
    init(){
        // Just reserved for the protocal
        print("Initializing the outlookCommunication")
    }
}

// MARK: Initialization Related
extension outlookCommunication{
    // ---------- MSAL Initialization ----------
    func initMSAL(parentViewController: UIViewController) throws {
        // authoruty URL (login)
        guard let authorityURL = URL(string: self.calendarAuthority) else {
            print("invalid url!")
            return
        }
        // Set calendarViewController for outlookCommunication
        self.CalendarViewController = (parentViewController as! CalendarDisp)
//        if self.CalendarViewController == nil{
//            print("Can't assign CalendarViewController for outlookCommunication")
//            return
//        }
        let authority = try MSALAADAuthority(url: authorityURL)
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: appId, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.webViewParamaters = MSALWebviewParameters(parentViewController: parentViewController)
        print("Parent View Controller: \(parentViewController)")
        print("initMSAL completed!")
        print("outlookCommunication's CalendarViewController setted!")
    }
    
    // ---------- Graph Initialization ----------
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

// MARK: Token Related
extension outlookCommunication{
    
    // Acquire token interactively (when there's no user signed in)
    // MARK: THIS FUNCTION CAN ONLY BE CALLED WHEN THERE'S A VIEW! (in viewDidAppear())
    func acquireTokenInteractively(){
        print("acquireTokenInteractively")
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        print("applicationContext and webViewParameters SETTED")
        
        let parameters = MSALInteractiveTokenParameters(scopes: self.graphScope, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount;
        
        applicationContext.acquireToken(with: parameters){(result, error) in
            print("In acquiring token")
            if let error = error{
               print("Could not acquire token: \(error)")
                return
            }
            guard let result = result else{
                print("Could not acquire token: No result returned")
                return
            }
            self.accessToken = result.accessToken
            print("!!!!!!!!!!Access token is \(self.accessToken)")
            self.getContentWithToken()
            print("Now token is got! It's inside the application of token(completion)")
            //print(self.CalendarViewController)
            self.CalendarViewController?.calendarID =  self.getUserCalendars()
            sleep(1)    // Wait until data returned
            for name in (self.CalendarViewController?.calendarID.keys)!{
                self.CalendarViewController?.calendarName.append(name) // calendar name
            }
            sleep(1)
            self.CalendarViewController?.InitDate()
            self.CalendarViewController?.dispCollectionView.reloadData()
            self.CalendarViewController?.eventCollectionView.reloadData()
        }
        print("It's outside the application of token!")
    }
    
    // Acquire token silently (when someone has signed in before and no more actions are needed)
    func acquireTokenSilently(_ account : MSALAccount!) {
        print("acquireTokenSilently")
        guard let applicationContext = self.applicationContext else { return }
        let parameters = MSALSilentTokenParameters(scopes: self.graphScope, account: account)
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            if let error = error {
                let nsError = error as NSError
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
            print("Refreshed Access token is \(self.accessToken)")
            self.getContentWithToken()
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
            print("Result from Graph: \(result)")
            
            }.resume()
    }
}

// MARK: User Account Related
extension outlookCommunication{
    func currentAccount() -> MSALAccount? {
        print("Getting Current Account!")
        guard let applicationContext = self.applicationContext else { return nil }
        print("applicationContext setted!")
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
    
    func signOut(){
        guard let applicationContext = self.applicationContext else { return }
        guard let account = self.currentAccount() else { return }
        
        do {
            try applicationContext.remove(account)
        } catch let error as NSError{
            print("Received error signing accout out: \(error)")
        }
    }
    
}

// MARK: Event Related
extension outlookCommunication{
    // Used to get events from outlook calendar
    func getEvents(inCalendar: String, startFrom: String, to: String){
        let calendarID = self.calendarDict[inCalendar] as! String
        //print(inCalendar)
        //print(startFrom)
        // Update loaded month to prevent repeat loading
        loadedMonth.insert(String(startFrom.prefix(7)))
        //print(loadedMonth)
        let requestLiteral = MSGraphBaseURL + "/me/calendars/\(calendarID)/events?$top=200&$filter=start/dateTime ge '\(startFrom)' and start/dateTime le '\(to)'" + "&$select=subject,body,start,end,location" + "&$orderBy=start/dateTime+ASC"
        let test = requestLiteral.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let eventsRequest = NSMutableURLRequest(url: URL(string: test!)!)
       // let eventsRequest = NSMutableURLRequest(url: URL(string: requestLiteral)!
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

    // Reserved to post event to user's specifid calendar
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
        print("with token: \(self.accessToken)")
        
        let getCalendarsRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/calendars")!)
        getCalendarsRequest.httpMethod = "GET"
        
        let getCalendarsDataTask = MSURLSessionDataTask(request: getCalendarsRequest, client: self.client, completion: {
                (data: Data?, response: URLResponse?, graphError: Error?) in
            if data == nil{
                //print(response)
                return
            }
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

    // Reserved for creating a calendar for current user
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

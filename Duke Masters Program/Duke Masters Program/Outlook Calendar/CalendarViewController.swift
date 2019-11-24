//
//  CalendarViewController.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 11/8/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit
import MSAL
import MSGraphMSALAuthProvider
import MSGraphClientSDK
import MSGraphClientModels

class CalendarViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate{
    
    //MSAL related
    let appId = "6446a4e7-b3db-4d57-9c8e-83bdcc796580"
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
    
    //Maybe need to be used later
    
    // for testing posting event
    @IBOutlet weak var testStart: UITextField!
    @IBOutlet weak var testEnd: UITextField!
    @IBOutlet weak var testSubject: UITextField!
    @IBOutlet weak var testBody: UITextField!
    
    // for testing getting event
    @IBOutlet weak var loggingText: UITextView!
    @IBOutlet weak var events: UITextView!
    
    @IBAction func getEvents(_ sender: UIButton) {
        //self.getEvents()
        //self.graphInit()
        self.graphEvent()
    }
    
    @IBAction func CreateEvents(_ sender: UIButton) {
        self.createEvent()
    }
    
    @IBAction func GetUserCalendars(_ sender: Any) {
        self.getUserCalendars()
    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for debugging
        print("Current in CalendarViewController!")
        self.updateLogging(text: "Current in CalendarViewController!")
        
        // initialize authentication related
        do{
            try self.initMSAL()
        } catch let error{
            self.updateLogging(text: "Unable to create Application context \(error)")
            print("initMSAL error")
        }
        
        print(assignments)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: token acquiring should be placed here,
    // since MSAL requires a valid window to represent ASWebAuthenticationSession
    // see https://github.com/AzureAD/microsoft-authentication-library-for-objc/issues/708 for details
    override func viewDidAppear(_ animated: Bool) {
        guard let currentAccount = self.currentAccount() else {
            // check to see whether there's a current logged in account.
            // If none, acquire token interactively.
            acquireTokenInteractively()
            self.graphInit()
            self.graphEvent()
            return
        }
        acquireTokenSilently(currentAccount)
        //self.getEvents()
        self.graphInit()
        self.graphEvent()
    }
}

// MARK: Initialization
extension CalendarViewController{
    
    func initMSAL() throws {
        
        // authoruty URL (login)
        guard let authorityURL = URL(string: self.calendarAuthority) else {
            print("invalid url!")
            return
        }

        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: appId, redirectUri: nil, authority: authority)
        
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        
        self.webViewParamaters = MSALWebviewParameters(parentViewController: self)
    }
    
    
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
//                var eventArray: [MSGraphEvent] = []
                
                eventsCollection.value.forEach({
                    (rawEvent: Any) in
                    // Convert JSON to a dictionary
                    guard let eventDict = rawEvent as? [String: Any] else {
                        return
                    }
                    // Deserialize event from the dictionary
                    let event = MSGraphEvent(dictionary: eventDict)!
//                    eventArray.append(event)
                    self.graphevents.append(event)
                })
                //print("\(eventArray)")
//                self.graphevents = eventArray
                var temp = ""
                for event in self.graphevents{
                    print("\(event.start!.dateTime)")
                    print(event.subject!)
                    let timeTemp = (event.start!.dateTime).components(separatedBy: ["T","."])
                    //temp.append(event.start)
                    temp += timeTemp[0] + " " + timeTemp[1]  + "\n"
                    temp += event.subject! + "\n"
                }
                // it's required that text of the view must be changed in the main thread
                if Thread.isMainThread{
                    self.events.text! = temp
                }
                else{
                    DispatchQueue.main.async {
                        self.events.text! = temp
                    }
                }
            } catch {
                //completion(nil, error)
            }
        })
        
        // Execute the request
        eventsDataTask?.execute()
    }
    
    func createEvent(){
        let urlRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/events")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("outlook.timezone=\"Pacific Standard Time\"", forHTTPHeaderField: "Prefer")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // function test 2
        let test2 = eventPreperation()
        test2.start.dateTime = testStart.text!
        test2.end.dateTime = testEnd.text!
        test2.subject = testSubject.text!
        test2.body = testBody.text!
        
        let test2Data = test2.eventToJSON()
        
        urlRequest.httpBody = test2Data
        let dataTask = MSURLSessionDataTask(request: urlRequest, client: self.client, completion: {
            (data: Data?, response: URLResponse?, error) in
            guard let backData = data, error == nil else{
                if error != nil{
                    print("error occurs")
                    //print("error in adding an event: \(error)")
                }
                return
            }
            print("data: \(backData)")
            if response != nil{
                print("response:")
                print("\(response!)")
                let temp = response as! HTTPURLResponse
                if temp.statusCode == 201{
                    if Thread.isMainThread{
                        let alert = UIAlertController(title:"Updated successfully",message: "Event sent to outlook calendar successfully!",preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title:"Updated successfully",message: "Event sent to outlook calendar successfully!",preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        dataTask?.execute()
    }
}



// MARK: Acquiring and using token
extension CalendarViewController{
    
    func acquireTokenInteractively(){
        print("acquireTokenInteractively")
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: self.graphScope, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount;

        applicationContext.acquireToken(with: parameters){(result, error) in

            if let error = error{
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }

            guard let result = result else{
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }

            self.accessToken = result.accessToken
            self.updateLogging(text: "Access token is \(self.accessToken)")
            self.getContentWithToken()
        }

    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        
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
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Access token is \(self.accessToken)")
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
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                self.updateLogging(text: "Couldn't deserialize result JSON")
                return
            }
            
            self.updateLogging(text: "Result from Graph: \(result))")
            
            print("Result from Graph: \(result)")
            
            }.resume()
    }
    
    func updateLogging(text : String) {
        
        if Thread.isMainThread {
            if self.loggingText != nil{
                self.loggingText.text = text
            }
        } else {
            DispatchQueue.main.async {
                self.loggingText.text = text
            }
        }
    }
}

extension CalendarViewController{
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
            
            self.updateLogging(text: "Didn't find any accounts in cache: \(error)")
        }
        
        return nil
    }
}

// MARK: get events
//let graphURL = "https://graph.microsoft.com/v1.0/me/"
extension CalendarViewController{
    func getEvents(){
        let select = "$select=subject,organizer,start,end"
        let orderBy = "$orderby=createdDateTime+DESC"
        
        let url = URL(string: graphURL + "events" + "?" + select + "&" + orderBy)
        var request = URLRequest(url: url!)
        
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error{
                self.events.text! = "Couldn't get graph result: \(error)"
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else{
                self.events.text! = "Couldn't deserializa result JSON"
                return
            }
//            DispatchQueue.main.async{
//                self.events.text! = "result from graph: \(result)"
//                print("Event Result: \(result)")
//            }
            print("Event Result: \(result)")
        }.resume()
    }
}


extension CalendarViewController{
    // Get calendars for current user
    func getUserCalendars(){
        
        print("Trying to get current user's calendars")
        
        let getCalendarsRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/calendars")!)
        getCalendarsRequest.httpMethod = "GET"
        
        let getCalendarsDataTask = MSURLSessionDataTask(request: getCalendarsRequest, client: self.client, completion: {
                (data: Data?, response: URLResponse?, graphError: Error?) in
//            guard let calendarData = try? JSONSerialization.jsonObject(with: data!, options: []) else{
//                           print("Couldn't deserialize result JSON")
//                           return
//                       }
            guard let calendarData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Any] else{
                print("Couldn't deserialize result JSON")
                return
            }
            //print(calendarData["@odata.context"]!)
            //print(calendarData["value"] ?? "Doesn't work!")
            let value = calendarData["value"] as! [[String: Any]]
            print(value.count)
            print(value[1]["name"] ?? "doesn't work!!!")
            
            print("Successfully got current user's calendars")
        })
    
        // Execute the request
        getCalendarsDataTask?.execute()
    
    }
}

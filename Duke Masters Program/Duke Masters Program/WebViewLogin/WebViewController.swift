//
//  WebViewController.swift
//  Duke Masters Program
//
//  Created by student on 11/17/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

//
//  WebViewController.swift
//  Duke Masters Program
//
//  Created by Nicolas Hu on 11/7/19.
//  Copyright © 2019 Duke University. All rights reserved.
//


// reference : https://developer.apple.com/documentation/webkit/wkwebview

import UIKit
import WebKit
import Firebase

import LocalAuthentication



var assignments : [(title: String, siteId: String, due: String, instructions: String)] = [] // load to calendar

//var userId : String = "" // userID on sakai,
// user info extracted
var userNetId : String = UserDefaults.standard.string(forKey: "netid") ?? "" // net ID
//var userEmail : String = "" // duke email
var userName : String = UserDefaults.standard.string(forKey: "name") ?? "" // this is used in netId
//var userAffiliations = [String]() // this depends, might be multiple
//var userPrimaryAffiliation : String = "" // only one, used in messaging



class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate{
    
    //-------------------
    // for query sakai
    var task : URLSessionTask!
    var sites = [String]()
    //default value for messaging
    var name = "Nobody"
    var email = "233333@gmail.com"
    var password = "whsdhrndndx" //only symbolic, no password saved
    var netid = "6666"
    var identity = "student"
    var userId = "" //for sakai
    //-------------------
    
    var webView: WKWebView! // create a new webview object
    
    // some URL strings
    var dukehubString = "https://dukehub.duke.edu/"
    var sissString = "https://ihprd.siss.duke.edu/"
    var dukehubSuccessString = "https://ihprd.siss.duke.edu/psp/IHPRD01/EMPLOYEE/EMPL/h/?tab=DU_IH_STUDENT"
    var sakaiString = "https://sakai.duke.edu"
    var sakaiPortalString = "https://sakai.duke.edu/portal"
    var netIdString = "https://api.colab.duke.edu/identity/v1/"
    
//    enum Result {
//        case success(HTTPURLResponse, Data)
//        case failure(Error)
//    }
//
//    var completionOnSubmit: ((Bool) -> Void)? // cookies saved
//    var completionOnInfo: ((Bool) -> Void)? // info has been extracted back

    
    // MARK: initialize webview
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration() // keep the default
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteLocalCookiesStorage() // delete all local cookies
        webView.loadString(sakaiString) // load url from string
        
        // faceID
        let status = UserDefaults.standard.bool(forKey: "status")
        let thisNetId = UserDefaults.standard.string(forKey: "netid") ?? ""
//        print("defaults status is:", status)
//        print("defaults netid is:", thisNetId)
        
        if status == true && thisNetId != ""{
            print("default status is:", status)
            print("defaults netid is:", thisNetId)
            localAuth()
        }
        
    }
    
    // using face ID to login, only when the user has logged in before
    func localAuth() {
        
        print("hello there!.. You have clicked the touch ID")
        
        let myContext = LAContext()
        let myLocalizedReasonString = "Biometric Authntication testing !! "
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            // User authenticated successfully, take appropriate action
                            print("debug: login using local auth")
                            
                            self.dismiss(animated: true, completion: {
                                // here we login succssfully
                                sleep(2)
                                self.performSegue(withIdentifier: "webviewToHome", sender: self)
                            })
                            
    
                            
                        } else {
                            // User did not authenticate successfully, look at error and take appropriate action
                            print("debug: failed to login using local auth")
                        }
                    }
                }
            } else {
                // Could not evaluate policy; look at authError and present an appropriate message to user
                print("debug:", "Sorry!!.. Could not evaluate policy.")
            }
        } else {
            // Fallback on earlier versions
            print("debug:", "Ooops!!.. This feature is not supported.")
        }
    }


    // MARK: 1. before navigagtion, check server redirect
    // called when web content begins to load in a web view
    // ref: from sakai app
//    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        print("ℹ️ debug: before navigation, url:", webView.url!.absoluteString)
//    }
    
    // MARK: 2. did commit
    // called when the web view begins to receive web content
//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        print("ℹ️ debug: did commit, url:", webView.url!.absoluteString)
//    }
    
    
    // MARK:3. did finish navigtion, check url
    // ref: from sakai app
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("ℹ️ debug: did finish navigation")
        
        // after navigation, if login successfully, perform segue
        if webView.url?.absoluteString == sakaiPortalString {
            print("ℹ️ debug: login success")
            DispatchQueue.main.async(execute: {
                self.getSakaiInfo() // now get info
                // Switcher update root VC
                UserDefaults.standard.set(true, forKey: "status")
                print("netid before setting key",userNetId)
                UserDefaults.standard.set(userNetId, forKey: "netid")
                UserDefaults.standard.set(userName, forKey: "name")
                Switcher.updateRootVC()
            })
            
        }
        else {
            print("ℹ️ debug: failed to log in")
            print("current url is :", webView.url!.absoluteString)
        }
    }
    
  
    // MARK: 4. Navigation Action
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void){
//
//        if (navigationAction.request.url?.absoluteString) != nil {
//            print("ℹ️ debug info: redirect happened here")
//            print(navigationAction.request.url?.absoluteString as Any)
//
//            decisionHandler(.allow)
//            return
//        }
//        decisionHandler(.allow)
//    }
    
    // MARK: 5. Navigation Response
    // save cookies if logged in correctly
    // on dismiss, perform segue and extract info
    func webView(_ webView: WKWebView,
    decidePolicyFor navigationResponse: WKNavigationResponse,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void){
        guard let response = navigationResponse.response as? HTTPURLResponse, let url = response.url else {
            decisionHandler(.cancel)
            return
        }
        
        // set cookies, only need to do this once
        if url.absoluteString == sakaiPortalString {
//            deleteLocalCookiesStorage() // reset cookies
            // only save cookies when the site == portal, should be only one time
            // here saving all the cookies from this WebView
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies {
                (cookies) in for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
//                    print("debug cookies:\n",cookie, "\n===================" )
                }
            }
//            webView.saveCurrentCookies(nil)
            
//            print("ℹ️ debug: navigation response: cookies saved")
//            print("ℹ️ debug: session cookies are, ", HTTPCookieStorage.shared.cookies!)
            
            self.dismiss(animated: true, completion: {
                // here we login succssfully
                sleep(2)
                self.performSegue(withIdentifier: "webviewToHome", sender: self)
            })
        }
        
//        // print header
//        if let headerFields = response.allHeaderFields as? [String: String]{
//            print("debug: check headers: url")
//            print(url.absoluteString)
//            print("headers", headerFields)
//        }
        // default decision, .allow
        decisionHandler(.allow)
//        print("ℹ️ debug: navigation response")
    }
    
    
    //MARK: get Sakai Site Info
    func getSakaiInfo() {
        // double check the if login successfully
        if !((webView.url?.absoluteString.hasPrefix(sakaiPortalString))!) {
//            print("debug: extract info: false portal")
            return
        }
        
        sites = [String]()
        // call sakai API
        let requestURL: NSURL = NSURL(string: "https://sakai.duke.edu/direct/membership.json?_limit=100")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        // use the saved cookies
        let session = URLSession.shared
        session.configuration.httpCookieStorage = HTTPCookieStorage.shared
        session.configuration.httpCookieAcceptPolicy = .always
        session.configuration.httpShouldSetCookies = true
        
        let targetString = "site:"
        
        let task = session.dataTask(with: urlRequest as URLRequest){
            (data, response, error) -> Void in
            guard let httpRes = response as? HTTPURLResponse, (200...299).contains(httpRes.statusCode) else {
                print("debug: get calendar: no response ")
                self.sites = []
//                userId = ""
//                userEmail = ""
                self.userId = ""
                userNetId = ""
                self.email = ""
                self.netid = ""
                return
            }
            // do
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                if let membership_collection = json["membership_collection"] as? [[String: AnyObject]] {
                    for membership in membership_collection {
//                        print("ℹ️ debug: membership")
                        
                        // this one is the site token
                        if let thisEntityId = membership["entityId"] as? String {
//                            print("ℹ️ debug: membership: site token is ", thisEntityId.components(separatedBy: targetString)[1] )
                            self.sites.append(thisEntityId.components(separatedBy: targetString)[1])
                        }
                        // this is email, take string before @ as netid
                        if let thisEid = membership["userEid"] as? String {
//                            userEmail = thisEid
//                            userNetId = thisEid.components(separatedBy: "@")[0]
//                            self.netid = userNetId
//                            self.email = userEmail
//                            print("ℹ️ debug: membership: netID", userId)
                            self.netid = thisEid.components(separatedBy: "@")[0]
                            self.email = thisEid
                            userNetId = self.netid
                            
                            UserDefaults.standard.set(userNetId, forKey: "netid")

                        }
                        // this is user Id on sakai, a token
                        if let thisId = membership["userId"] as? String {
//                            print("ℹ️ debug: membership: user token is ", thisId )
//                            userId = thisId
                            self.userId = thisId // id on sakai
//                            print("debug: self.userId", self.userId)
                        }
                        

                    }
                }
                else {
                    print("ℹ️ debug: no such object in json")
                }
                
            }
            catch {
                print("ℹ️ debug: error with json", error)
            }
            // aftet get info, do the get assignment
//            print("ℹ️ debug: sakai info: netid is ", userNetId)
            print("ℹ️ debug: sakai info: netid is ", self.netid, ".")
//            print("ℹ️ debug: sakai info: now get assignments")
            
            
            // dispatch
            DispatchQueue.main.async(execute: {
                self.getSakaiAssignment()
                self.getNetIdResults(netid: self.netid)
                
            })
            
            // now we have the basic user info
            // call other functions, to extract information
//            self.getSakaiAssignment()
//            self.getNetIdResults(netid: self.netid)
            
            // adding the firebase login
//            print("fan_test 1, before handler", self.name)
////            print("fan_test, before handler, global", userName)
//            self.handleRegister()
//            print("fan_test 1, after handler: ", self.name)
            
            
            
        }
        // after let task
        task.resume()
//        // this userID always prints empty, but when I pause it, it's not empty
//        print("ℹ️ debug: sakai info: netid is ", userNetId)
//        print("ℹ️ debug: sakai info: now get assignments")
//        self.getSakaiAssignment()
    }
    
    
    //MARK: get Assginment schedules for calendar
    func getSakaiAssignment() {
        assignments = []
//        print("ℹ️ debug: sakai assignment ")
        if sites.count == 0 {
            print("ℹ️ debug: assignment: empty sites, return")
            return
        }
        
        
        for site in sites {
            let thisURL = "https://sakai.duke.edu/direct/assignment/site/" + site + ".json"
            let thisRequestURL : NSURL = NSURL(string: thisURL)!
            let thisRequest : NSMutableURLRequest = NSMutableURLRequest(url: thisRequestURL as URL)
            
            // use the saved cookies
            let session = URLSession.shared
            session.configuration.httpCookieStorage = HTTPCookieStorage.shared
            session.configuration.httpCookieAcceptPolicy = .always
            session.configuration.httpShouldSetCookies = true
            
//            print("ℹ️ debug: assignment: this URL", thisURL)
            
            let task = session.dataTask(with: thisRequest as URLRequest) { (data, response, error) -> Void in
                let httpRes = response as? HTTPURLResponse
                if httpRes == nil {
                    print("ℹ️ debug: get assignments : no response ")
                    assignments = []
                    return
                }

                if httpRes?.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: AnyObject]
//                        print("ℹ️ debug: get assignments, json is ", json)
                        if let assignment_collection = json["assignment_collection"] as? [[String: AnyObject]]{
                            for assignment in assignment_collection{
                                
//                                print("ℹ️ debug: assignment")
                                var title : String = "assignment"
                                let siteID : String = site
                                var due : String = "due"
                                var instructions : String = "instructions"
                                // assignment title
                                if let thisTitle = assignment["title"] as? String {
                                    title = thisTitle
                                }
                                // assignment due time
                                if let thisDue = assignment["dueTimeString"] as? String {
                                    due = thisDue
                                }
                                // assignment instructions
                                if let thisInstructions = assignment["instructions"] as? String {
                                    instructions = thisInstructions
                                }
                                // add new assignment
                                let tuple = (title, siteID, due, instructions)
                                assignments.append(tuple)
                            }// end for loop in assignments
                        } // end assignment collection

                    }// end do
                    catch {
                        print("Error with Json: \(error)")
                    }
                }// end if
//                print("ℹ️ debug: get assignments, status code is ", httpRes?.statusCode)
//                print("ℹ️ debug: assignments: all done")
            }// end task, for this site
            task.resume()
            
        } // end for loop of sites
//        print("ℹ️ debug: all assignments done")
//        print(assignments)
    }
    
    
    //MARK: get NetId Results, colab API
    func getNetIdResults(netid : String) {
        
        let thisString = netIdString.appending(netid)
        print("ℹ️ debug: netID: ",thisString)
        let thisURL = URL(string: thisString)!
        var thisRequest = URLRequest(url: thisURL)
        thisRequest.httpMethod = "GET"
        thisRequest.addValue("api-docs", forHTTPHeaderField: "x-api-key")
        
        let session = URLSession.shared
        session.configuration.httpCookieStorage = HTTPCookieStorage.shared
        session.configuration.httpCookieAcceptPolicy = .always
        session.configuration.httpShouldSetCookies = true

        let task = session.dataTask(with: thisRequest as URLRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("ℹ️ Debug: Error: colab netid api returns no response.")
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("ℹ️ Debug: Error: colab netid api returns status code.", httpResponse.statusCode)
                return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data {
                do  {
                    let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as! [String: AnyObject]
//                    print("ℹ️ debug: netid: json result")
//                    print (json)
                    if let thisName = json["displayName"] as? String {
                        userName = thisName
                        self.name = thisName
                        UserDefaults.standard.set(userName, forKey: "name")

                        
                    }
                    if let thisPri = json["eduPersonPrimaryAffiliation"] as? String {
//                        userPrimaryAffiliation = thisPri
//                        self.identity = userPrimaryAffiliation
                        self.identity = thisPri
                    }
//                    if let thisAff = json["affiliations"] as? [String] {
//                        userAffiliations = thisAff
//                    }
                    print("ℹ️ debug: netid: results")
//                    print(userName, userPrimaryAffiliation, userAffiliations )
                    print(self.name, self.identity, "\n============")
                    
                }
                catch {
                    print("error is , ", error)
                } // end catch
                
            } // end if
            
            // adding the firebase login
            print("fan_test2, before handler", self.name)
//            print("fan_test, before handler, global", userName)
            self.handleRegister()
            print("fan_test2: after hndler ", self.name)
//            print("fan_test, after handler, global", userName)
        }// end task
        task.resume()
    }
    

    // MARK: update home page
    // update the home page text with the course descriptions
    func updateHomePageTextView() {
        let homeVC : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homePageVC") as UIViewController
        let textView = UITextView()
        textView.text = assignments.description
        homeVC.view.addSubview(textView)
    }
    
    
    //MARK: firebase: register new user
    // if user first time use this app, it will automatically register an account on firebase
    // if he/she has an account, then login the account
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
        })
    }
    
    //MARK: firebase: login user
    func loginUser(){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            //successfully logged in our user
            print("successfully logged in our user")
        })
    
    }
    
    // MARK: firebase: handle register
    func handleRegister() {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                let errorCode = error.unsafelyUnwrapped;
                //"auth/email-already-in-use"
                if (errorCode.localizedDescription == "The email address is already in use by another account.") {
                        self.loginUser()
                }
                print(error ?? "")
                return
            }
                  
            guard let uid = user?.user.uid else {
                return
            }
            
            let values = ["name": self.name, "email": self.email, "netid": self.netid, "identity": self.identity]
            
            self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
              //successfully authenticated user

        })
    } // end of function

} // end of the class


extension WKWebView {
    // shortcut for load a website from string
    func loadString (_ urlString : String ) {
        if let url = URL(string: urlString){
            let request = URLRequest(url: url)
            load(request)
        }
    }
    
    func saveCurrentCookies(_ prefixString : String?){
        
        // if url match, save the cookies.
        if (url?.absoluteString.hasPrefix(prefixString!))!{
            configuration.websiteDataStore.httpCookieStore.getAllCookies{ cookies in for cookie in cookies {
                print("current cookies: ", cookie)
                HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }
        // if no url provided, save ALL cookies
        if prefixString == nil {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies {
                (cookies) in for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
            
        }
        
        
    }
   
    
}




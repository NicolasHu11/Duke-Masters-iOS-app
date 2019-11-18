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

var task : URLSessionTask!
var userId : String = "" // the user ID on sakai
var userNetId : String = "" // net ID
var userEmail : String = ""
var sites = [String]()
var assignments : [(title: String, siteId: String, due: String, instructions: String)] = []

// this is used in netId
var userName = ""
var userAffiliations = [String]()
var userPrimaryAffiliation : String = ""



class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate{
    
    var name = "Fan"
    var email = "fandy1996v@gmail.com"
    var password = "Zhangfan1996"
    var netid = "fz48"
    var identity = "student"
    //-------------------
    
    var webView: WKWebView! // create a new webview object
    
    var dukehubString = "https://dukehub.duke.edu/"
    var sissString = "https://ihprd.siss.duke.edu/"
    
    var dukehubSuccessString = "https://ihprd.siss.duke.edu/psp/IHPRD01/EMPLOYEE/EMPL/h/?tab=DU_IH_STUDENT"
    var sakaiString = "https://sakai.duke.edu"
    var sakaiPortalString = "https://sakai.duke.edu/portal"
    var netIdString = "https://api.colab.duke.edu/identity/v1/"
    
    
    enum Result {
        case success(HTTPURLResponse, Data)
        case failure(Error)
    }
    
    var completionOnSubmit: ((Bool) -> Void)? // cookies saved
    var completionOnInfo: ((Bool) -> Void)? // info has been extracted back
//
//    completionOnSubmit = { _ in print("debug: submit done")}
//
//    completionOnInfo = {}
    
    // MARK: initialize webview: nav bar + webview
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration() // keep the default
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        
    }
 
    // dismiss keyboard
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load url from string
        webView.loadString(sakaiString)
        
        // use the shared cookies
        let session = URLSession.shared
        session.configuration.httpCookieStorage = HTTPCookieStorage.shared
        session.configuration.httpCookieAcceptPolicy = .always
        session.configuration.httpShouldSetCookies = true
        
//        // check cookies
//        var cookies = readCookie(forURL: myURL!)
//        print("debug: Cookies BEFORE request: ", cookies)
//        // check cookies
//        cookies = readCookie(forURL: myURL!)
//        print("debug: Cookies AFTER request: ", cookies)
        
//
//        // tap gesture to dismiss keyboard
//        // dont need this since on phone, there's bar
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyBoard))
//        self.view.addGestureRecognizer(tap)

    }


    // MARK: 1. before navigagtion, check server redirect
    // called when web content begins to load in a web view
    // ref: from sakai app
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {

//        print("ℹ️ debug: before navigation, url:", webView.url!.absoluteString)
    }
    
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
//        if (webView.url?.absoluteString.hasPrefix(sakaiPortalString))! {
//            print("ℹ️ debug: login success")
            // now get info
            self.getSakaiInfo()
//            handleRegister()
//            print("fan_test: ", self.name)
//            self.getSakaiAssignment()
            // present to the home page
//            self.performSegue(withIdentifier: "webviewToHome", sender: self)

            
        }
        else {
            print("ℹ️ debug: failed to log in")
            print("url is :", webView.url!.absoluteString)
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
    
    // MARK: Navigation Response
    // here save cookies if logged in correctly
    func webView(_ webView: WKWebView,
    decidePolicyFor navigationResponse: WKNavigationResponse,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void){
        // guard response
        guard let response = navigationResponse.response as? HTTPURLResponse, let url = response.url else {
            decisionHandler(.cancel)
            return
        }
        
        // set cookies, only need to do this once
        if url.absoluteString == sakaiPortalString {
            // only save cookies when the site == portal, should be only one time
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies {
                (cookies) in for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
//            print("ℹ️ debug: navigation response: cookies saved")
//            print("ℹ️ debug: session cookies are, ", HTTPCookieStorage.shared.cookies!)
            
            self.dismiss(animated: true, completion: {
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
        // this should be just strings, or something like Calendar infor?
        
        // double check the if login successfully
        if !((webView.url?.absoluteString.hasPrefix(sakaiPortalString))!) {
//            print("debug: extract info: false portal")
            return
        }
        
        sites = [String]()
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
                sites = []
                userId = ""
                userEmail = ""
                userNetId = ""
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
                            sites.append(thisEntityId.components(separatedBy: targetString)[1])
                        }
                        // this is email, take string before @ as netid
                        if let thisEid = membership["userEid"] as? String {
                            userEmail = thisEid
                            userNetId = thisEid.components(separatedBy: "@")[0]
                            self.netid = userNetId
                            self.email = userEmail
//                            print("ℹ️ debug: membership: netID", userId)
                        }
                        // this is user Id on sakai, a token
                        if let thisId = membership["userId"] as? String {
//                            print("ℹ️ debug: membership: user token is ", thisId )
                            userId = thisId
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
            print("ℹ️ debug: sakai info: netid is ", userNetId)
//            print("ℹ️ debug: sakai info: now get assignments")
            self.getSakaiAssignment()
            self.getNetIdResults(netid: userNetId)
            
            // adding the firebase login
            print("fan_test, before handler", self.name)
            print("fan_test, before handler, global", userName)
            self.handleRegister()
            print("fan_test: ", self.name)
            
            
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
    
    //MARK: get NetId Results
    func getNetIdResults(netid : String) {
        // should return class or string?
        // this is the data structure we need to have, in firebase
        // for now, save as global varaibles
        
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
            //
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
                        self.name = userName
                    }
                    if let thisPri = json["eduPersonPrimaryAffiliation"] as? String {
                        userPrimaryAffiliation = thisPri
                        self.identity = userPrimaryAffiliation
                    }
                    if let thisAff = json["affiliations"] as? [String] {
                        userAffiliations = thisAff
                    }
                    print("ℹ️ debug: netid: results")
                    print(userName, userPrimaryAffiliation, userAffiliations )
                    
                }
                catch {
                    print("error is , ", error)
                } // end catch
                
            } // end if
            
            // adding the firebase login
            print("fan_test, before handler", self.name)
            print("fan_test, before handler, global", userName)
            self.handleRegister()
            print("fan_test: ", self.name)
            print("fan_test, after handler, global", userName)
        }// end task
        
        task.resume()
 
    }
    


    // MARK: update home page
    // update the home page text with the course descriptions
    func updateHomePageTextView() {
        let homeVC : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homePageVC") as UIViewController
        let textView = UITextView()
//        textView.text = courses.description
        homeVC.view.addSubview(textView)
        
    }
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
                  let ref = Database.database().reference()
                  let usersReference = ref.child("users").child(uid)
                  
                  usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                      
                      if err != nil {
                          print(err ?? "")
                          return
                      }
                      
          //            self.messagesController?.fetchUserAndSetupNavBarTitle()
          //            self.messagesController?.navigationItem.title = values["name"] as? String
                      //let user = User(dictionary: values)
                      //self.messagesController?.setupNavBarWithUser(user)
                      
                      //self.dismiss(animated: true, completion: nil)
                  })
              }
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
                  /*
                  let imageName = UUID().uuidString
                  let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
                  
                  //if let profileImage = self.profileImageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
                  
                      storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                          
                          if let error = error {
                              print(error)
                              return
                          }
                          
                          storageRef.downloadURL(completion: { (url, err) in
                              if let err = err {
                                  print(err)
                                  return
                              }
                              
                              guard let url = url else { return }
                              let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString]
                              
                              self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                          })
                          
                      })
                  }
       */
              })
              

          }

// end of the class
}


extension WKWebView {
    // shortcut for load a website from string
    func loadString (_ urlString : String ) {
        if let url = URL(string: urlString){
            let request = URLRequest(url: url)
            load(request)
        }
    }
    
    func saveCurrentCookies(_ prefixString : String ){
        // if url match, save the cookies.
        if (url?.absoluteString.hasPrefix(prefixString))!{
            configuration.websiteDataStore.httpCookieStore.getAllCookies{ cookies in for cookie in cookies {
            print("current cookies: ", cookie)
            HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    }
   
    
}




//
//  chatCollectionViewController.swift
//  Duke Masters Program
//
//  Created by student on 11/9/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let itemsPerRow : CGFloat = 1.0
private let sectionInsets = UIEdgeInsets(top: 50.0,left: 15.0,bottom: 110.0,right: 15.0)

//var curUsers = User()
var Username = ""
var Useremails = ""
var UserIndentity = ""
var Messageuser = ""
class chatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    var users = [User]()
    //flag control for showing students/staff messages, default: staff messages
    var allstudent_flag = true
    var inputtextBottomAnchor: NSLayoutConstraint?
    lazy var inputTextview: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self as UITextViewDelegate
        tv.scrollsToTop = false
        tv.isScrollEnabled = false
        tv.font = UIFont(name: "Courier", size: 20)
        return tv
    }()
   //left bar button, show student/staff message
    @IBOutlet weak var controlFlag: UIBarButtonItem!
    
//    override func viewDidAppear(_ animated: Bool) {
//        self.collectionView.reloadData()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.users = []
        
        
        //change the title of left bar button
        if(allstudent_flag){
            controlFlag.title = "show student"
            navigationItem.title = "STAFF"
        }else{
            controlFlag.title = "show staff"
            navigationItem.title = "STUDENT"
        }
        //find the current user info
        findUser()
        //initialize collection view
        prepare()
        setupInputComponents()
        //get messages from firebase
        updateMessage()
        //keyboard moving
        setupKeyboardObservers()
        textViewDidChange(inputTextview)
        //give enough time for loading data from database
        sleep(1)
    }
    func prepare(){
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -40).isActive = true
        collectionView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    func setupInputComponents() {
        
         //MARK:set Inputtextview
           view.addSubview(inputTextview)
        inputTextview.backgroundColor = .white
        inputtextBottomAnchor = inputTextview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputtextBottomAnchor?.isActive = true
        inputTextview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        inputTextview.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -15).isActive = true
           inputTextview.heightAnchor.constraint(equalToConstant: 40).isActive = true
            //send no text if textview is empty
            inputTextview.enablesReturnKeyAutomatically = true
            inputTextview.keyboardType = .default
            inputTextview.returnKeyType = .send
        inputTextview.layer.cornerRadius = 10.0
        inputTextview.layer.borderWidth = 2.0
        inputTextview.layer.borderColor = UIColor.lightGray.cgColor
       }
    
    //MARK: enlarge textview height
    func textViewDidChange(_ textView: UITextView ) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let esti_size = textView.sizeThatFits(size)
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                if esti_size.height < 110{
                constraint.constant = esti_size.height
                
                }
                else{
                    textView.isScrollEnabled = true
                }
            }
            
        }
    }
     
    //Find the login user info
    func findUser(){
        print("hello world")
        guard let uid = Auth.auth().currentUser?.uid
            else {
             //for some reason uid = nil
             return
         }
    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
        if let dictionary = snapshot.value as? [String: AnyObject] {
                print("Fetch Info ", dictionary)
            //print("try iden: ", snapshot)
            Username = (dictionary["name"] as? String)!
            Useremails = (dictionary["email"] as? String)!
            UserIndentity = (dictionary["identity"] as? String)!
//            Messageuser = (dictionary["message"] as? String)!
            print("testUser",Username)
                    //self.setupNavBarWithUser(user)
                }
                
                }, withCancel: nil)

    }
    //MARK: update message list every ? s
    func updateMessage(){
        self.users = []
        if(allstudent_flag){
            controlFlag.title = "show student"
            navigationItem.title = "STAFF"
        }else{
            controlFlag.title = "show staff"
            navigationItem.title = "STUDENT"
        }
//        DispatchQueue.main.async(execute: {
//            self.collectionView.reloadData()
//        })
    }
    //MARK: Grap the info from firebase
    func fetchUser(tablename: String) {
       // self.users = []
            Database.database().reference().child(tablename).observe(.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                    self.users.insert(user,at:0)
                    print("users:", self.users)
                }
                
                }, withCancel: nil)

        }
    //refresh the page
    @IBAction func clickReload(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    //left button action, change the flag to control staff/student
    @IBAction func clickAction(_ sender: Any) {
        
//        updateMessage()
        DispatchQueue.main.async(execute: {
            self.allstudent_flag = !self.allstudent_flag
            if(self.allstudent_flag){
                self.controlFlag.title = "show student"
                self.navigationItem.title = "STAFF"
            }else{
                self.controlFlag.title = "show staff"
                self.navigationItem.title = "STUDENT"
            }
            self.updateMessage()
            self.collectionView.reloadData()
                    print("change!")

        })
//        collectionView.reloadData()
    }
    //save messages to the database when send messages
    @objc func handleSend() {
        
        var messageType = "messages"
        if(UserIndentity == "staff"){
            messageType = "Main_messages"
        }
        let ref = Database.database().reference().child(messageType)
        let childRef = ref.childByAutoId()
        //get info of current login user
        guard let fromId = Auth.auth().currentUser?.uid
           else {
            //for some reason uid = nil
            return
        }
        //let fromId = Auth.auth().currentUser!.uid
        let time = convertDate(NSDate())
        let emails = Useremails
        let curUserName = Username
        //include following aspects inside the message node
        //text: content of messages  fromId: the UID of sender
        let values = ["text": inputTextview.text!, "name": curUserName, "email": emails, "fromId":fromId, "time":time]
        // upload messages to Firebase
        childRef.updateChildValues(values)
        // finish upload
        self.collectionView.reloadData()
       
    }
    //MARK: SEND PRESS IN ACTION
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text.isEqual("\n")){
            print("worked")
            handleSend()
            textView.text = nil
            return false
        }
        return true
    }
    
    //MARK: textfield moving when using keyboard
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       }
       @objc func handleKeyboardWillShow(_ notification: Notification) {
           let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
           let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
           
           inputtextBottomAnchor?.constant = -keyboardFrame!.height
           UIView.animate(withDuration: keyboardDuration!, animations: {
               self.view.layoutIfNeeded()
           })
       }
       
       @objc func handleKeyboardWillHide(_ notification: Notification) {
           let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
           
           inputtextBottomAnchor?.constant = 0
           UIView.animate(withDuration: keyboardDuration!, animations: {
               self.view.layoutIfNeeded()
           })
       }
       
    

    
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           handleSend()
       
           return true
        
       }
    
// MARK: compute each item size THINK ABOUT HOW TO ADPOTIVE IT
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
      let availableWidth = view.frame.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
      return CGSize(width: widthPerItem, height: 150)
    }
    
    //  MARK: Space between cells
     func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    // control space between each lines
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return users.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatMessageCell
        let users_message = users[indexPath.item]
        let temp =  users_message.name! + " " + (users_message.date ?? "00:00 0000" )
        cell.TextView.text = temp
        cell.MessageView.text = users_message.message
        return cell
    }
    func convertDate(_ rawDate : NSDate?)->String{
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.locale = NSLocale.current
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        let newDate = formatter.string(from: rawDate! as Date)

        return newDate
    }
   
}


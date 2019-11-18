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
private let sectionInsets = UIEdgeInsets(top: 50.0,left: 15.0,bottom: 100.0,right: 15.0)
//var curUsers = User()
var Username = ""
var Useremails = ""
var Messageuser = ""
class chatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var users = [User]()
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat Log Controller"
        findUser()
        prepare()
        
        fetchUser()
        setupInputComponents()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
       // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    func prepare(){
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 55).isActive = true
        collectionView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView?.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    func setupInputComponents() {
           let containerView = UIView()
           containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
           view.addSubview(containerView)
           
           //ios9 constraint anchors
           //x,y,w,h
           containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
           containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
           containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
           containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
           
           let sendButton = UIButton(type: .system)
           sendButton.setTitle("Send", for: UIControl.State())
           sendButton.translatesAutoresizingMaskIntoConstraints = false
           sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
           containerView.addSubview(sendButton)
           //x,y,w,h
           sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
           sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
           sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
           sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
           
           containerView.addSubview(inputTextField)
           //x,y,w,h
           inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
           inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
           inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
           inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
           
           let separatorLineView = UIView()
        
           separatorLineView.backgroundColor = UIColor(displayP3Red: 220, green: 220, blue: 220, alpha: 1)
           separatorLineView.translatesAutoresizingMaskIntoConstraints = false
           containerView.addSubview(separatorLineView)
           //x,y,w,h
           separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
           separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
           separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
           separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
       }
    func findUser(){
        guard let uid = Auth.auth().currentUser?.uid
         else {
             //for some reason uid = nil
             return
         }
    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
        if let dictionary = snapshot.value as? [String: AnyObject] {
                print("Fetch Info ", dictionary)
            Username = (dictionary["name"] as? String)!
            Useremails = (dictionary["email"] as? String)!
//            Messageuser = (dictionary["message"] as? String)!
//            print("Messageuser",Messageuser)
                    //self.setupNavBarWithUser(user)
                }
                
                }, withCancel: nil)

    }
    func fetchUser() {
        self.users = []
            Database.database().reference().child("messages").observe(.childAdded, with: { (snapshot) in
                print(snapshot)
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    
                    //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                    
                    self.users.insert(user,at:0)
                    print("users:", self.users)
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                    
    //                user.name = dictionary["name"]
                }
                
                }, withCancel: nil)

        }
       @objc func handleSend() {
        
        //send message to database
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let time = convertDate(NSDate())
        
        let emails = Useremails
        let curUserName = Username
        //is it there best thing to include the name inside of the message node
        let values = ["text": inputTextField.text!, "name": curUserName, "email": emails, "fromId":fromId, "time":time]
        // upload messages to Firebase
        childRef.updateChildValues(values)
        // finish upload
        print("Finish send: handle send")
        self.collectionView.reloadData()
       
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
      
      return CGSize(width: widthPerItem, height: widthPerItem)
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
        cell.TextView.text = temp//users_message.message + users_message.date
        cell.MessageView.text = users_message.message
//        var cell_date = convertDate(users_message.date)
        // Configure the cell
//        print(cell_date)
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
    //
//    func collectionView(_ collectionView:UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: 80)
//    }

}

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
//var curUsers = User()
var Username = ""
var Useremails = ""

class chatCollectionViewController: UICollectionViewController, UITextFieldDelegate {
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
        collectionView?.backgroundColor = UIColor.white
        
        setupInputComponents()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
       // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    func setupInputComponents() {
           let containerView = UIView()
           containerView.translatesAutoresizingMaskIntoConstraints = false
           
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
                print("first", dictionary)
            Username = (dictionary["name"] as? String)!
            Useremails = (dictionary["email"] as? String)!
            print(Username)
                    //self.setupNavBarWithUser(user)
                }
                
                }, withCancel: nil)

    }
       @objc func handleSend() {
        
        //send message to database
           let ref = Database.database().reference().child("messages")
           let childRef = ref.childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let emails = Useremails
        let curUserName = Username
        print("curName", curUserName)
           //is it there best thing to include the name inside of the message node
        let values = ["text": inputTextField.text!, "name": curUserName, "email": emails, "fromId":fromId]
           childRef.updateChildValues(values)
           performSegue(withIdentifier: "showMessage", sender: Any?.self)
        
       }
       
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           handleSend()
       
           return true
        
       }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
 

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

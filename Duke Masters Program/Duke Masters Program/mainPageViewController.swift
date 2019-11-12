//
//  mainPageViewController.swift
//  Duke Masters Program
//
//  Created by student on 11/11/19.
//  Copyright © 2019 Duke University. All rights reserved.
//
import Firebase
import UIKit

class mainPageViewController: UIViewController {

    let name = "Fan"
    let email = "fandy1996v@gmail.com"
    let password = "Zhangfan1996"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleRegister()
        // Do any additional setup after loading the view.
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
                if (errorCode.localizedDescription == "auth/email-already-in-use") {
                    self.loginUser()
                }
                print(error ?? "")
                return
            }
            
            guard let uid = user?.user.uid else {
                return
            }
            let values = ["name": self.name, "email": self.email]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

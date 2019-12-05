//
//  SidebarViewController.swift
//  Duke Masters Program
//
//  Created by student on 10/26/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit

class SidebarViewController: UIViewController {
   // let page = UIView(frame: self.view.bounds)
    @IBOutlet weak var sideName: UILabel!
    @IBOutlet weak var sideNetID: UILabel!
    @IBOutlet weak var sideEmail: UITextField!
    
    @IBAction func logoutUser(_ sender: Any) {
        
        UserDefaults.standard.set("", forKey: "netid")
        UserDefaults.standard.set("", forKey: "name")
        UserDefaults.standard.set(false, forKey: "status")
        
        // reset global values in webviewVC
        assignments = []
        userName = ""
        userNetId = ""
        deleteLocalCookiesStorage()
        
        self.performSegue(withIdentifier: "sidebarToLogin", sender: nil)
        print("debug: segue to webview")
        
//        let loginVC = WebViewController()
//        let homeVC : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homePageVC") as UIViewController
//        self.present(WebViewController(), animated: true, completion: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFields()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"bg3.png")!)
        // Do any additional setup after loading the view.
    }
    
    func updateFields() {
        // update fields in sidebar
        if userNetId != "" {
            sideNetID.text = userNetId
            sideEmail.text = userNetId + "@duke.edu"
        } else {
            print("debug: netid is empty")
        }
        if userName != ""{
            sideName.text = userName
        } else {
            print("debug: username is empty")
        }

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

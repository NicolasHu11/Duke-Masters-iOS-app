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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFields()
       
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"bg3.png")!)
        // Do any additional setup after loading the view.
    }
    
    func updateFields() {
        if userNetId != "" {
            sideNetID.text = userNetId
        }
        if userName != ""{
            sideName.text = userName
        }
        if userEmail != ""{
            sideEmail.text = userEmail
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

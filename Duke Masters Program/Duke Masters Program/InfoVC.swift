//
//  InfoVC.swift
//  MEM_directory
//
//  Created by student on 10/27/19.
//  Copyright © 2019 student. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {
    var Name_fromtable = String()
    var Email_fromtable  = String()
    var Image__fromtable  = UIImage()
    
    
    @IBOutlet weak var Info_Email: UILabel!
    
    @IBOutlet weak var Info_Des: UILabel!
    @IBOutlet weak var Info_Name: UILabel!
    @IBOutlet weak var Info_Image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Info_Name.text! = Name_fromtable
        Info_Email.text! = Email_fromtable
        // Do any additional setup after loading the view.
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

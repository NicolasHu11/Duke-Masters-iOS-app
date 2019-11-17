//
//  Detail_VC.swift
//  ToDoList_PJ
//
//  Created by student on 11/6/19.
//  Copyright © 2019 student. All rights reserved.
//

import UIKit

class Detail_VC: UIViewController {
    var Name_fromtable = String()
    var Descri_fromtable  = [String]()
    @IBOutlet weak var Itemname: UILabel!
    @IBOutlet weak var Description: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // rearrange the descriotion for printout
        var sentences = String()
        for index in 0..<Descri_fromtable.count {
           sentences += Descri_fromtable[index]
            if index != Descri_fromtable.count-1{
                sentences += "\n"
            }
        }
        Description.text = sentences
        Itemname.text = Name_fromtable
        Description.isEditable = false
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

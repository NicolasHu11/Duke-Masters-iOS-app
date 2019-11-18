//
//  Button_VC.swift
//  ToDoList_PJ
//
//  Created by student on 11/6/19.
//  Copyright © 2019 student. All rights reserved.
//

import UIKit

class Button_VC: UIViewController {

    @IBOutlet weak var Graduate: UIButton!
    @IBOutlet weak var First_year: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func Firstyear_pressed(_ sender: Any) {
        print("First year was pressed")
    }
    @IBAction func Graduate_pressed(_ sender: Any) {
        print("Graduate was pressed")

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Firstyearsegue") {
            guard let vc = segue.destination as? ToDoList_TableVC else {
                return
            }
            //prepare data for further initialnize
            vc.fresh_grad = "Firstyear"
            print("\(vc.fresh_grad)")
           
            //assign string to next view controller instance from selected cell.
           
            
        }
        if(segue.identifier == "Graduatesegue") {
            guard let vc = segue.destination as? ToDoList_TableVC else {
                return
            }
            //prepare data for further initialnize
            vc.fresh_grad = "graduate"
            print("\(vc.fresh_grad)")
           
            //assign string to next view controller instance from selected cell.
           
            
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

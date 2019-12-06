//
//  SafetyPageViewController.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 10/24/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit

class SafetyPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func Call911(_ sender: Any) {
        print("CALL 911!")
        self.CALL("CALL 911", number: "911")
    }
    
    @IBAction func CallDukePolice(_ sender: Any) {
        print("CALL Duke Police!")
        self.CALL("CALL Duke Police", number: "919-684-2444")
    }
    
    @IBAction func CallOandE(_ sender: Any) {
        print("CALL O&E Safety!")
        self.CALL("CALL O&E Safety", number: "919-684-2794")
    }
    
    // Note that this only works in cell phone, but not on simulator
    func CALL(_ call: String, number: String){
        let controller = UIAlertController(title: call, message: "\(number)", preferredStyle: .actionSheet)
        let phoneAction = UIAlertAction(title: call, style: .default){ (_) in
            if let url = URL(string: "tel://\(number)"){
                print(url)
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
                else{
                    print("Can't open url!")
                }
            }
            else{
                print("Invalid url!")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(phoneAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func toLiveSafe(_ sender: Any) {
   
    if let url = URL(string: "livesafeapp://"){
            print(url)
            if UIApplication.shared.canOpenURL(url) == true{
                print("Open liveSafe app!")
                UIApplication.shared.open(url)
            }
            else{
                print("Please install liveSafe app first!")
                if let spareUrl = URL(string: "itms-apps://itunes.apple.com/app/id653666211"){
                    print("download url is \(spareUrl)")
                    if UIApplication.shared.canOpenURL(spareUrl){
                        print("Open App store!")
                        UIApplication.shared.open(spareUrl)
                    }
                    else{
                        print("似乎碰到了什么夭寿的bug？？？")
                    }
                }
            }
        }
        else{
            print("Invalid url!")
        }
    }
}

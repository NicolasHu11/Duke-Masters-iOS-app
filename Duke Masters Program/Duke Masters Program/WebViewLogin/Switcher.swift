//
//  Switcher.swift
//  Duke Masters Program
//
//  Created by Nicolas Hu on 11/19/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import Foundation
import UIKit
// this class is used to update root VC for login and re-login

class Switcher {

    static func updateRootVC(){
        
        let status = UserDefaults.standard.bool(forKey: "status")
        var rootVC : UIViewController?
       
        print("ℹ️ Debug: current status:",status)
        if(status == true){
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homePageVC") as! mainPageViewController
            print("ℹ️ Debug: update root to homepage")
        }else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webLogin") as! WebViewController
            print("ℹ️ Debug: update root to Login")

        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.window != nil {
            appDelegate.window!.rootViewController = rootVC// this line is nil
            print("ℹ️ Debug: root vc updated to window")
        } else {
            print("debug: UI window is nil")
        }
        
        
   
    }
    
}

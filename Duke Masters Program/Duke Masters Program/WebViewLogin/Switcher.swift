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
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homePage") as! mainPageViewController
        }else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webLogin") as! WebViewController
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = rootVC
        
    }
    
}

//
//  RoomReservationViewController.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 10/27/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit
import WebKit

class RoomReservationViewController: UIViewController{

    @IBOutlet weak var RoomReservationWeb: WKWebView!
    override func viewDidLoad() {
        //super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.addSubview(RoomReservationWeb)
        let webLink = "https://library.duke.edu/using/room-reservations"
        //let webLink = "http://duke.libcal.com/reserve/perkins"
        let url = URL(string: webLink)!
        RoomReservationWeb.load(URLRequest(url:url))
        //Add swipe back and forth gestures
        RoomReservationWeb.addGestureRecognizer(backGesture)
        RoomReservationWeb.addGestureRecognizer(forwardGesture)
    }
    
    private lazy var backGesture = { () -> UISwipeGestureRecognizer in
        let g = UISwipeGestureRecognizer(target: self, action: #selector(self.back))
        g.direction = UISwipeGestureRecognizer.Direction.right  // from left to right
        return g
    }()
    
    private lazy var forwardGesture = { () -> UISwipeGestureRecognizer in
        let g = UISwipeGestureRecognizer(target: self, action: #selector(self.forward))
        g.direction = UISwipeGestureRecognizer.Direction.left
        return g
    }()

    @IBAction func back(_ recognizer: UISwipeGestureRecognizer) {
        if (self.RoomReservationWeb.canGoBack) {
            self.RoomReservationWeb.goBack()
        }
    }
    
    @IBAction func forward(_ recognizer: UISwipeGestureRecognizer) {
        if (self.RoomReservationWeb.canGoForward) {
            self.RoomReservationWeb.goForward()
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

//
//  ViewController.swift
//  Move
//
//  Created by Samar Sunkaria on 3/28/19.
//  Copyright © 2019 samar. All rights reserved.
//

import UIKit
import CoreMotion
import WatchConnectivity

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["message" : "Hello"], replyHandler: { (reply) in
                print(reply["message"]!)
            }, errorHandler: nil)
        }
    }
    
    @IBAction func toggleWorkoutTapped(_ sender: UIButton) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["message" : "Workout"], replyHandler: nil, errorHandler: nil)
        }
    }
    
}

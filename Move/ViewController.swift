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

    @IBOutlet var textLabel: UILabel!
    @IBOutlet var stopButton: UIButton!
    var timer: Timer?

    var lastAction: Action?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startGame)))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func startGame() {
        WCSession.default.sendMessage(["message" : "start"], replyHandler: { (reply) in
            DispatchQueue.main.async {
                self.setupGame()
            }
        }, errorHandler: nil)
    }

    func setupGame() {
        stopButton.isHidden = false
        showNewAction()
        refreshTimer()
    }

    func refreshTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (_) in
            self.showNewAction()
        })
    }

    func showNewAction() {
        var newAction = Action.allCases.randomElement()!
        while newAction == lastAction {
            newAction = Action.allCases.randomElement()!
        }

        textLabel.text = newAction.rawValue.uppercased()
        view.backgroundColor = newAction.color()
        lastAction = newAction
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        WCSession.default.sendMessage(["message" : "stop"], replyHandler: { (reply) in
            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.textLabel.text = "TAP TO START!"
                self.view.backgroundColor = #colorLiteral(red: 0.7058823529, green: 0.6431372549, blue: 0.6901960784, alpha: 1)
                self.stopButton.isHidden = true
            }
        }, errorHandler: nil)
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch connectivity session activationDidComplete")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch connectivity sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch connectivity sessionDidDeactivate")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard
            let actionName = message["message"] as? String,
            let action = Action(rawValue: actionName)
        else {
            return
        }

        if action == lastAction {
            DispatchQueue.main.async {
                self.showNewAction()
                self.refreshTimer()
            }
        }
    }
}

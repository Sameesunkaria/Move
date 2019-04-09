//
//  InterfaceController.swift
//  MoveWatch Extension
//
//  Created by Samar Sunkaria on 3/30/19.
//  Copyright © 2019 samar. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion
import HealthKit

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var watchLabel: WKInterfaceLabel!
    
    var workoutSession: HKWorkoutSession?
    let healthStore = HKHealthStore()
    
    let manager = CMMotionManager()
    
    var lastThreshold = Date()
    let sampleInterval = 1 / 50.0


    var recentlyDetected = false
    var counter = 0
    
    var accumuletedAccelerationAlongGravity = 0.0
    var accumulatedAccelerationAlongX = 0.0
    var accumulatedRateAlongGravity = 0.0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    func setupWorkoutSession() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .indoor
        
        do {
            self.workoutSession = try HKWorkoutSession(healthStore: self.healthStore, configuration: workoutConfiguration)
            self.workoutSession!.startActivity(with: Date())
            
            
        } catch {
            print("could not start a workout")
        }
    }
    
    func endWorkoutSession() {
        self.workoutSession?.end()
        self.workoutSession = nil
    }
    
    func setupMotionDataCapture() {
        guard manager.isAccelerometerAvailable else { fatalError("Accelerometer not available") }
        manager.deviceMotionUpdateInterval = sampleInterval

        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { (data, error) in
            guard let data = data, error == nil else { return }
            
            let accelerationAlongX = data.userAcceleration.x // along arm
            
            let accelerationAlongGravity =
                data.userAcceleration.x * data.gravity.x +
                    data.userAcceleration.y * data.gravity.y +
                    data.userAcceleration.z * data.gravity.z
            
            let rateAlongGravity =
                data.rotationRate.x * data.gravity.x +
                    data.rotationRate.y * data.gravity.y +
                    data.rotationRate.z * data.gravity.z
            
            self.counter += 1
            if self.counter == 25 {
                self.recentlyDetected = false
                self.counter = 0
            }
            
            if !self.recentlyDetected {
                if 4.5 < accelerationAlongX, accelerationAlongGravity < -3.75 {
                    WCSession.default.sendMessage(["message" : "hurray"], replyHandler: nil, errorHandler: nil)
                    
                    print("hurray")
                    self.recentlyDetected = true
                } else if 4.5 < accelerationAlongX {
                    WCSession.default.sendMessage(["message" : "punch"], replyHandler: nil, errorHandler: nil)
                    
                    print("punch")
                    self.recentlyDetected = true
                } else if 1 < accelerationAlongX, accelerationAlongX < 4.5, 5.5 < rateAlongGravity, rateAlongGravity < 10, -1 < accelerationAlongGravity, accelerationAlongGravity < 0 {
                    WCSession.default.sendMessage(["message" : "clap"], replyHandler: nil, errorHandler: nil)

                    print("clap")
                    self.recentlyDetected = true
                }
            }
            
            
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch connectivity session activationDidComplete")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if !session.isReachable {
            endWorkoutSession()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["message"] as? String == "start" {
            setupMotionDataCapture()
            setupWorkoutSession()
            DispatchQueue.main.async {
                self.watchLabel.setText("well, there should be some text")
            }
            replyHandler(["message" : "started"])
        }
        
        if message["message"] as? String == "stop" {
            endWorkoutSession()
            manager.stopDeviceMotionUpdates()
            DispatchQueue.main.async {
                self.watchLabel.setText("Go to your iPhone to start!")
            }
            replyHandler(["message" : "stopped"])
        }
    }
}


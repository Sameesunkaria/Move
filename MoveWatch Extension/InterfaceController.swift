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

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var interfaceGroup: WKInterfaceGroup!
    
    let manager = CMMotionManager()
    
    var lastThreshold = Date()
    let sampleInterval = 1 / 50.0
    var accelerationAlongXBuffer = [Double]()
    var accelerationAlongYBuffer = [Double]()
    var accelerationAlongZBuffer = [Double]()
    var pitchBuffer = [Double]()
    var rollBuffer = [Double]()
    var yawBuffer = [Double]()
    var movementIsStarted = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        
        guard manager.isAccelerometerAvailable else { fatalError("Accelerometer not available") }
        manager.deviceMotionUpdateInterval = sampleInterval
        
        if !movementIsStarted {
            
            DispatchQueue.main.async {
                self.interfaceGroup.setBackgroundColor(.red)
            }
            
            manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) {
                [weak self] (data, error) in
                
                guard let self = self, let data = data, error == nil else {
                    return
                }
                
                let accelerationAlongX = data.userAcceleration.x
                let accelerationAlongY = data.userAcceleration.y
                let accelerationAlongZ = data.userAcceleration.z
                
                self.accelerationAlongXBuffer.append(accelerationAlongX)
                self.accelerationAlongYBuffer.append(accelerationAlongY)
                self.accelerationAlongZBuffer.append(accelerationAlongZ)
                
                self.pitchBuffer.append(data.attitude.pitch)
                self.rollBuffer.append(data.attitude.roll)
                self.yawBuffer.append(data.attitude.yaw)
                
            }
            
            movementIsStarted = true
        } else {
            
            DispatchQueue.main.async {
                self.interfaceGroup.setBackgroundColor(.black)
            }
            
            let accumulatedVelocityAlongX = self.accelerationAlongXBuffer.reduce(0.0, +) * self.sampleInterval
            let accumulatedVelocityAlongY = self.accelerationAlongYBuffer.reduce(0.0, +) * self.sampleInterval
            let accumulatedVelocityAlongZ = self.accelerationAlongZBuffer.reduce(0.0, +) * self.sampleInterval
            
            guard !pitchBuffer.isEmpty, !rollBuffer.isEmpty, !yawBuffer.isEmpty else { return }
            
            let pitchChange = pitchBuffer.last! - pitchBuffer.first!
            let rollChange = rollBuffer.last! - rollBuffer.first!
            let yawChange = yawBuffer.last! - yawBuffer.first!
            
            print("\(accumulatedVelocityAlongX), \(accumulatedVelocityAlongY), \(accumulatedVelocityAlongZ), \(pitchChange), \(rollChange), \(yawChange)")
            
            accelerationAlongXBuffer = []
            accelerationAlongYBuffer = []
            accelerationAlongZBuffer = []
            
            movementIsStarted = false
        }
        
    }
    

}

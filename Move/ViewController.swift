//
//  ViewController.swift
//  Move
//
//  Created by Samar Sunkaria on 3/28/19.
//  Copyright © 2019 samar. All rights reserved.
//

import UIKit
import CoreMotion

struct Vector {
    var x: Double
    var y: Double
    var z: Double

    static let zero = Vector(x: 0, y: 0, z: 0)
}

class ViewController: UIViewController {

    let manager = CMMotionManager()
    var vector = Vector.zero

    var lastThreshold = Date()
    let sampleInterval = 1 / 50.0
    let accelerationAlongGravityBuffer = RunningBuffer(size: 50)


    override func viewDidLoad() {
        super.viewDidLoad()

        guard manager.isAccelerometerAvailable else { fatalError("Accelerometer not available") }

        manager.deviceMotionUpdateInterval = sampleInterval

        manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) {
            [weak self] (data, error) in

            guard let self = self, let data = data, error == nil else {
                return
            }
            
            let horizontalVector = data.magneticField
            
            let accelerationAlongGravity =
                data.userAcceleration.x * data.gravity.x +
                data.userAcceleration.y * data.gravity.y +
                data.userAcceleration.z * data.gravity.z
            
            let accelerationMagnitude =
                pow(data.userAcceleration.x, 2) +
                pow(data.userAcceleration.y, 2) +
                pow(data.userAcceleration.z, 2)
            
            let accelerationPerpendicularToGravity = sqrt(accelerationMagnitude - pow(accelerationAlongGravity, 2))
            
            self.accelerationAlongGravityBuffer.addSample(accelerationAlongGravity)

            
            if !self.accelerationAlongGravityBuffer.isFull() {
                return
            }
            
            let accumulatedVelocityAlongGravity = self.accelerationAlongGravityBuffer.sum() * self.sampleInterval
//            let accumulatedVelocityPerpendicularToGravity =

            
            
//            let peakAcceleration = accumulatedVelocity > 0 ? self.accelerationAlongZBuffer.max() : self.accelerationAlongZBuffer.min()
            
//            print("accumulated velocity: \(accumulatedVelocity)")
//            print("peak acceleration: \(peakAcceleration)")
            
//            print("\(accumulatedVelocityAlongGravity), \(accelerationAlongGravity), \(horizontalVector)")
            print("\(data.attitude.yaw), \(data.attitude.pitch), \(data.attitude.roll)")
            
//            if (accumulatedVelocity > velocityTreshold && peakAcceleration > acceleration) {
//                print("up movement")
//            }
        }

    }


}


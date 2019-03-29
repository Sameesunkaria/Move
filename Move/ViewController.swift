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

    override func viewDidLoad() {
        super.viewDidLoad()

        guard manager.isAccelerometerAvailable else { fatalError("Accelerometer not available") }

        manager.deviceMotionUpdateInterval = 0.01

        manager.startDeviceMotionUpdates(to: .main) {
            [weak self] (data, error) in

            guard let self = self, let data = data, error == nil else {
                return
            }

            print("\(data.userAcceleration.x), \(data.userAcceleration.y), \(data.userAcceleration.z)")
        }

    }


}


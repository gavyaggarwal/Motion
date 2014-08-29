//
//  MotionDetector.swift
//  Motion
//
//  Created by Gavy Aggarwal on 6/15/14.
//  Copyright (c) 2014 Feist Apps. All rights reserved.
//

import Foundation
import CoreMotion

protocol MotionDetectorDelegate {
    func positionUpdated(value: String)
    func velocityUpdated(value: String)
    func accelerationUpdated(value: String)
}

class MotionDetector:NSObject {
    var delegate : MotionDetectorDelegate?
    var motionManager : CMMotionManager
    var updateDate : NSDate
    var accelerationX : CDouble
    var accelerationY : CDouble
    var accelerationZ : CDouble
    var velocityX : CDouble
    var velocityY : CDouble
    var velocityZ : CDouble
    var positionX : CDouble
    var positionY : CDouble
    var positionZ : CDouble
    
    init(delegate: MotionDetectorDelegate) {
        self.delegate = delegate;
        motionManager = CMMotionManager()
        updateDate = NSDate()
        accelerationX = 0.0;
        accelerationY = 0.0;
        accelerationZ = 0.0;
        velocityX = 0.0;
        velocityY = 0.0;
        velocityZ = 0.0;
        positionX = 0.0;
        positionY = 0.0;
        positionZ = 0.0;
    }
    
    func start() {
        motionManager.startDeviceMotionUpdates()
        motionManager.deviceMotionUpdateInterval = 0.001
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateData", userInfo: nil, repeats: true);
        
        self.delegate?.positionUpdated("13 m")
        self.delegate?.velocityUpdated("19 m/s")
        self.delegate?.accelerationUpdated("12 m/s" + "\u00B2")
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func updateData() {
        //var gravity = motionManager.deviceMotion?.gravity
        var userAccelation = motionManager.deviceMotion?.userAcceleration
        var gravity = motionManager.deviceMotion?.gravity
        
        
        var gX : CDouble! = (gravity?.x) ? gravity?.x : 0
        var gY : CDouble! = (gravity?.y) ? gravity?.y : 0
        var gZ : CDouble! = (gravity?.z) ? gravity?.z : 0
        
        //if gZ is -1, than the device is upright (flat, screen up) and motion in X goes x, y goes y, and Z goes z
        //if gY is -1, then the device's charger is facing the ground and motion in X goes X, Y goes Z, and Z goes y
        //if gX is -1, then volume botton faces down and motion in X goes in z plane, Y goes in X, and Z goes
        
        //NSLog("GRAVITY: %f %f %f", gX, gY, gZ)
        
        var accelX : CDouble! = (userAccelation?.x) ? userAccelation?.x : 0
        var accelY : CDouble! = (userAccelation?.y) ? userAccelation?.y : 0;
        var accelZ : CDouble! = (userAccelation?.z) ? userAccelation?.z : 0;
        
        NSLog("CROSS PRODUCT: <%f %f %f>", accelY * gZ - accelZ * gY, accelZ * gX - accelX * gZ, accelX * gY - accelY * gX)
        
        self.accelerationX = accelX * 9.80665
        self.accelerationY = accelY * 9.80665
        self.accelerationZ = accelZ * 9.80665
        
        var time = self.updateDate.timeIntervalSinceNow
        
        //Delta velocities
        var dVelocityX = (-time) * self.accelerationX
        var dVelocityY = (-time) * self.accelerationY
        var dVelocityZ = (-time) * self.accelerationZ
        
        //Total velocities
        self.velocityX += dVelocityX
        self.velocityY += dVelocityY
        self.velocityZ += dVelocityZ
        
        //Delta positions
        var dPositionX = (time) * (time) * self.accelerationX * 0.5 + self.velocityX * (-time)
        var dPositionY = (time) * (time) * self.accelerationY * 0.5 + self.velocityY * (-time)
        var dPositionZ = (time) * (time) * self.accelerationZ * 0.5 + self.velocityZ * (-time)
        
        //Total positions
        self.positionX += dPositionX
        self.positionY += dPositionY
        self.positionZ += dPositionZ
        
        self.updateDate = NSDate();
        
        var totalAccel = pythagorean(self.accelerationX, y: self.accelerationY, z: self.accelerationZ)
        var totalVel = pythagorean(self.velocityX, y: self.velocityY, z: self.velocityZ)
        var totalPos = pythagorean(self.positionX, y: self.positionY, z: self.positionZ)
        
        var roundedAccel = round(10 * totalAccel) / 10
        var roundedVel = round(10 * totalVel) / 10
        var roundedPos = round(10 * totalPos) / 10
        
        var formattedAccel = "\(roundedAccel) m/s" + "\u00B2"
        var formattedVel = "\(roundedVel) m/s"
        var formattedPos = "\(roundedPos) m"
        
        self.delegate?.accelerationUpdated(formattedAccel)
        self.delegate?.velocityUpdated(formattedVel)
        self.delegate?.positionUpdated(formattedPos)
        
        //NSLog("x: \(accelX) y: \(accelY) Total: \(totalAccel! * 9.81) m/s" + "\u00B2")
        //NSLog("Acceleration: %f, %f, %f", self.accelerationX, self.accelerationY, self.accelerationZ)
        //NSLog("Velocity:     %f, %f, %f", self.velocityX, self.velocityY, self.velocityZ)
        //NSLog("Position:     %f, %f, %f", self.positionX, self.positionY, self.positionZ)
    }
    
    func pythagorean(x: CDouble, y: CDouble, z: CDouble) -> CDouble {
        return sqrt(x * x + y * y + z * z)
    }
}
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
    
    var shouldBreak = false
    
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
        
        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "shouldUpdateData", userInfo: nil, repeats: true);
        
        self.delegate?.positionUpdated("13 m")
        self.delegate?.velocityUpdated("19 m/s")
        self.delegate?.accelerationUpdated("12 m/s" + "\u{00B2}")
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func reset() {
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
        
        //updateData()
    }
    
    func breakPoint() {
        shouldBreak = true;
    }
    
    func shouldUpdateData() {
        var userAcceleration = motionManager.deviceMotion?.userAcceleration
        
        var accelX : CDouble! = (userAcceleration?.x != nil) ? userAcceleration?.x : 0
        var accelY : CDouble! = (userAcceleration?.y != nil) ? userAcceleration?.y : 0;
        var accelZ : CDouble! = (userAcceleration?.z != nil) ? userAcceleration?.z : 0;
        
        if(abs(accelX) > 0.05 || abs(accelY) > 0.05 || abs(accelZ) > 0.05) {
            updateData(accelX, accelY: accelY, accelZ: accelZ)
        } else {
            updateData(0, accelY: 0, accelZ: 0)
        }
    }
    
    func updateData(accelX:Double, accelY:Double, accelZ:Double) {
        //var gravity = motionManager.deviceMotion?.gravity
        var userAcceleration = motionManager.deviceMotion?.userAcceleration
        var gravity = motionManager.deviceMotion?.gravity
        
        
        var gX : CDouble! = (gravity?.x != nil) ? gravity?.x : 0
        var gY : CDouble! = (gravity?.y != nil) ? gravity?.y : 0
        var gZ : CDouble! = (gravity?.z != nil) ? gravity?.z : 0
        
        //if gZ is -1, than the device is upright (flat, screen up) and motion in X goes x, y goes y, and Z goes z
        //if gY is -1, then the device's charger is facing the ground and motion in X goes X, Y goes Z, and Z goes y
        //if gX is -1, then volume botton faces down and motion in X goes in z plane, Y goes in X, and Z goes
        
        var aZ : Double = atan(Double(gZ) / sqrt(gX * gX + gY * gY))
        //aZ contains the angle of the device's orientation to the ground with respect to the Z axis
        //Thanks Eric from StackOverflow!
        
        //NSLog("Gravity: x: %f, y: %f, z: %f", gX, gY, gZ)
        
        //NSLog("CROSS PRODUCT: <%f %f %f>", accelY * gZ - accelZ * gY, accelZ * gX - accelX * gZ, accelX * gY - accelY * gX)
        
        self.accelerationX = accelX * 9.80665
        self.accelerationY = (accelY * gZ + accelZ * gY + accelZ * gX) * 9.80665
        self.accelerationZ = (accelZ * gZ + accelY * gY + accelX * gX) * 9.80665
        
        if (shouldBreak) {
            shouldBreak = !shouldBreak;
            var a = accelZ * gZ * 9.80665
            var b = accelY * gY * 9.80665
            var c = accelX * gX * 9.80665
            
        }
        
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
        
        var roundedAccel = round(10 * self.accelerationZ) / 10
        var roundedVel = round(10 * self.velocityZ) / 10
        var roundedPos = round(10 * self.positionZ) / 10
        
        var formattedAccel = "\(roundedAccel) m/s" + "\u{00B2}"
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
    
    func RadiansToDegrees (value:Double) -> Double {
        return value * 180.0 / M_PI
    }
}
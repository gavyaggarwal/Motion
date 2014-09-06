//
//  ViewController.swift
//  Motion
//
//  Created by Gavy Aggarwal on 6/15/14.
//  Copyright (c) 2014 Feist Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MotionDetectorDelegate {
    @IBOutlet var positionLabel : UILabel?
    @IBOutlet var velocityLabel : UILabel?
    @IBOutlet var accelerationLabel : UILabel?
    
    var motionDetector: MotionDetector?
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        motionDetector = MotionDetector(delegate: self);
        motionDetector?.start()
    }
    
//MARK: warning add function to disable motion detector

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reset(sender: AnyObject) {
        motionDetector?.reset()
    }
    @IBAction func breakPoint(sender: AnyObject) {
        motionDetector?.breakPoint()
    }
    
    func positionUpdated(value: String) {
        positionLabel?.text = value;
    }
    func velocityUpdated(value: String)  {
        velocityLabel?.text = value
    }
    func accelerationUpdated(value: String)  {
        accelerationLabel?.text = value;
    }


}


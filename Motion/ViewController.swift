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
    @IBOutlet var graphView: GraphView!
    
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
    
    func positionUpdated(value: String) {
        graphView.addX(0, y: 1, z: 2)
        positionLabel?.text = value;
    }
    func velocityUpdated(value: String)  {
        velocityLabel?.text = value
    }
    func accelerationUpdated(value: String)  {
        accelerationLabel?.text = value;
    }


}


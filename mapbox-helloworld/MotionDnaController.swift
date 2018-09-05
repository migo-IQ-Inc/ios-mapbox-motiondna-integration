//
//  MotionDnaController.swift
//  mapbox-helloworld
//
//  Created by Lucas Mckenna on 8/30/18.
//  Copyright © 2018 Lucas Mckenna. All rights reserved.
//

import Foundation
import MotionDnaSDK
import Mapbox

class MotionDnaController : MotionDnaSDK
{
    var m : MGLMapView?
    var receiver_ : MotionDnaLocationManager?
    func start(_ receiver : MotionDnaLocationManager){
        // "Enter your Navisens developer key, please inquire it here: https://navisens.com/"
        runMotionDna("key", receiver: self)
        setExternalPositioningState(HIGH_ACCURACY)
        receiver_=receiver
    }
    
    override func receive(_ motionDna: MotionDna!) {
        receiver_?.receive(motionDna)
    }
    
    
    override func reportError(_ error: ErrorCode, withMessage message: String!) {
        // Error
        if (error==AUTHENTICATION_FAILED)
        {
            receiver_?.authFailure()
        }
    }
}

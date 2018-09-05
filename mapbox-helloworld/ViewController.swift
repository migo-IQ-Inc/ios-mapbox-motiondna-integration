//
//  ViewController.swift
//  mapbox-helloworld
//
//  Created by Lucas Mckenna on 8/30/18.
//  Copyright © 2018 Lucas Mckenna. All rights reserved.
//

import UIKit
import Mapbox
import CoreGraphics
import MotionDnaSDK

class ViewController: UIViewController, MGLMapViewDelegate {
    let navisensLocationManager = MotionDnaLocationManager(authorizationStatus: CLAuthorizationStatus.authorizedAlways)
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.styleURL = MGLStyle.streetsStyleURL
        // Override MapView internal LocationManager
        navisensLocationManager.view = self
        mapView.locationManager = navisensLocationManager
//        mode so that the arrow will appear.
        mapView.userTrackingMode = .followWithHeading
        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        mapView.showsUserLocation=true
        view.addSubview(mapView)
    }
}

class MotionDnaLocationManager : NSObject, MGLLocationManager{
    
    override func `self`() -> Self {
        return self
    }

    var delegate: MGLLocationManagerDelegate?
    let controller = MotionDnaController()
    var view:ViewController?
    

    var authorizationStatus: CLAuthorizationStatus

    init (authorizationStatus: CLAuthorizationStatus?){
        self.authorizationStatus = authorizationStatus! // it has a chance so its value can be set!
    }
    
    func requestAlwaysAuthorization() {
        controller.setExternalPositioningState(HIGH_ACCURACY)
    }
    
    func requestWhenInUseAuthorization() {
        controller.setExternalPositioningState(HIGH_ACCURACY)
    }
    
    func receive(_ motionDna: MotionDna!)
    {
        // Here I am mapping our MotionDna type to Apple's CLLocation type which is the expected type for MGLLocationManager.
        let date = Date(timeIntervalSince1970: motionDna.getTimestamp())
        var currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: motionDna.getLocation().globalLocation.latitude, longitude: motionDna.getLocation().globalLocation.longitude), altitude: CLLocationDistance(motionDna.getLocation().absoluteAltitude), horizontalAccuracy: CLLocationAccuracy(motionDna.getLocation().uncertainty.x), verticalAccuracy: CLLocationAccuracy(motionDna.getLocation().absoluteAltitudeUncertainty), course: CLLocationDirection(motionDna.getLocation().heading), speed: CLLocationDistance(motionDna.getMotion().stepFrequency),
                                         timestamp: date)
        var positions: [CLLocation] = []
        positions.append(currentLocation)
        DispatchQueue.main.async{
            
            // Need to find a way to assign a CLHeading type from our internal magneticHeading/heading types from MotionDna.getLocation()
            self.delegate?.locationManager(self, didUpdate: positions)
        }
    }
    
    func authFailure(){
        // Authentication failure.
        let alert = UIAlertController(title: "Authentication failure", message: "Please enter your developer key in the MotionDnaController.swift runMotionDna method. Get your key here: https://navisens.com/ ", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        view?.present(alert, animated: true, completion: nil)
    }
    
    func startUpdatingLocation() {
        controller.start(self)
        controller.setLocationNavisens()// Configures SDK to use our complete positioning
    }
    
    func stopUpdatingLocation() {
        controller.stop()
    }
    
    var headingOrientation: CLDeviceOrientation = CLDeviceOrientation(rawValue: 10)!
    
    func startUpdatingHeading() {
        // No need to implement since heading integration runs when estimating a position.
    }
    
    func stopUpdatingHeading() {
        
    }
    
    func dismissHeadingCalibrationDisplay() {
        
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return false
    }
}

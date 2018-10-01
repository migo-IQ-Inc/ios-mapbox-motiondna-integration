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
        // mode so that the arrow will appear.
        mapView.userTrackingMode = .followWithHeading
        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        mapView.showsUserLocation=true
        view.addSubview(mapView)
    }
}

class MotionDnaLocationManager : NSObject, MGLLocationManager, MotionDnaLocationManagerDelegate{
    func locationManager(_ manager: MotionDnaLocationManagerDataSource!, didUpdate locations: [CLLocation]!) {
        DispatchQueue.main.async{
            // Output positions
            self.delegate?.locationManager(self, didUpdate: locations)
        }
    }
    
    func locationManager(_ manager: MotionDnaLocationManagerDataSource!, didFailWithError error: Error?) {
        let cas = error! as NSError // Xcode is converting our NSError to an Error wrongly in the delegate auto completion, therefore we need to cast it...
        
        if (cas.code == AUTHENTICATION_FAILED.rawValue)
        {
            DispatchQueue.main.async{
                self.authFailure()
            }
        }
    }
    
    func locationManager(_ manager: MotionDnaLocationManagerDataSource!, didUpdate newHeading: CLHeading!) {
        DispatchQueue.main.async{
            // Output heading
            self.delegate?.locationManager(self, didUpdate: newHeading)
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: MotionDnaLocationManagerDataSource!) -> Bool {
        return false
    }
    
    override func `self`() -> Self {
        return self
    }

    var delegate: MGLLocationManagerDelegate?
    let sdk = MotionDnaSDK()
    var view:ViewController?
    

    var authorizationStatus: CLAuthorizationStatus

    init (authorizationStatus: CLAuthorizationStatus?){
        self.authorizationStatus = authorizationStatus! // it has a chance so its value can be set!
    }
    
    func requestAlwaysAuthorization() {
        sdk.setExternalPositioningState(HIGH_ACCURACY)
    }
    
    func requestWhenInUseAuthorization() {
        sdk.setExternalPositioningState(HIGH_ACCURACY)
    }
    
    func authFailure(){
        // Authentication failure.
        let alert = UIAlertController(title: "Authentication failure", message: "Please enter your developer key in the ViewController.swift runMotionDna method. Get your key here: https://navisens.com/ ", preferredStyle: UIAlertControllerStyle.alert)
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
        sdk.runMotionDna("YOURDEVELOPERKEY")
        sdk.motionDnaDelegate=self
        sdk.setExternalPositioningState(HIGH_ACCURACY)
        sdk.setBinaryFileLoggingEnabled(true)
        sdk.setLocationNavisens()// Configures SDK to use our complete positioning.
//        sdk.setLocationLatitude(37.787742, longitude: -122.396859, andHeadingInDegrees: 315)// Configures SDK to start our inertial estimate from a specific lat/lon/heading.
    }
    
    func stopUpdatingLocation() {
        sdk.stop()
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

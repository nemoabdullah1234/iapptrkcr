//
//  AKMQTTMapViewController.swift
//  Stryker
//
//  Created by Nitin Singh on 17/07/17.
//  Copyright © 2017 OSSCube. All rights reserved.
//

import UIKit

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}


class AKMQTTMapViewController: UIViewController {
   
    var URL:String?
    var shipmentNo:String?
    var status:String!
    var statusCode: NSInteger?
    var lat:String!
    var long:String!
    var fromlat:String!
    var fromlong:String!
    var fromAddress: Dictionary<String, AnyObject>!
    var toAddress:String!
    var shipmentID:String!
    var destinationAnnotation : Bool?
    var sourceAnnotation : Bool?
    var destinationLocation : String!
    var didFindMyLocation = false
    var locationManager = CLLocationManager()
   
    var mapTasks = MapTasks()
    
    var locationMarker: GMSMarker!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var travelMode = TravelModes.driving
    
    
    @IBOutlet weak var viewMap: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         customizeNavigationforAll(self)
         self.title = "Map"
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 28.7041, longitude: 77.1025, zoom: 8.0)
        viewMap.camera = camera
        viewMap.delegate = self
        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        
        // Do any additional setup after loading the view.
    }
 
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
   {
    if !didFindMyLocation {
        let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
        viewMap.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
        viewMap.settings.myLocationButton = true
        
        didFindMyLocation = true
    }
   }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func backToDashbaord(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }
    func poptoPreviousScreen(){
        self.navigationController?.popViewController(animated: true)
    }
    func sortButtonClicked(_ sender : AnyObject){
        
    }

    

}
extension AKMQTTMapViewController : CLLocationManagerDelegate
{
    // MARK: CLLocationManagerDelegate method implementation
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            viewMap.isMyLocationEnabled = true
        }
    }
}

extension AKMQTTMapViewController : GMSMapViewDelegate
{
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if let polyline = routePolyline {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            print(positionString)
            waypointsArray.append(positionString)
            
           // recreateRoute()
        }
    }
}


//
//  AKMapViewController.swift
//  Stryker
//
//  Created by Nitin Singh on 08/06/17.
//  Copyright © 2017 OSSCube. All rights reserved.
//

import UIKit
import MapKit
import AWSCore
import AWSIoT
import SwiftyJSON
import AKProximity

let reuseId = "pin"

class CustomPointAnnotation: MKPointAnnotation {
    var pinCustomImageName:String!
}

class AKMapViewController: UIViewController, MKMapViewDelegate {

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
    var angle = 0
    var timer: Timer!
    var userPinView: MKAnnotationView!
    var lastCoordinates : MKAnnotation?
    var destinationCordinate  : MKAnnotation?
    @IBOutlet weak var mapView: MKMapView!
    var annotations:Array = [Station]()
    var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeTopic()
        self.title = "IOT Map"
       // let annotations = getMapAnnotations()
        customizeNavigationforAll(self)
        // Add mappoints to Map
     //   mapView.addAnnotations(annotations)
        customNavigationforBack(self)
        self.navigationItem.titleView = STRNavigationTitle.setTitle("\(self.shipmentNo!)", subheading: "\(status!)")
        mapView.delegate = self
  
        // Change the Map Region to the first lon/lat in the array of dictionaries
        let regionLongitude = Double(long)
        let regionLatitude = Double(lat)
        let coordinate = BeaconHandler.sharedHandler.coordinate
        destinationCordinate = Station(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
        self.lastCoordinates = destinationCordinate as? MKAnnotation
        destinationAnnotation = true
        sourceAnnotation = true
        displayRegionIncomeLevel(lattitudeMQtt: regionLatitude!, longtitudeMQTT: regionLongitude!)
        
        let fromLongitude = Double(fromlong)
        let fromLatitude = Double(fromlat)
        displayRegionIncomeLevel(lattitudeMQtt: fromLatitude!, longtitudeMQTT: fromLongitude!)
        
        var source : MKMapItem!
        var destination : MKMapItem!
        if #available(iOS 10.0, *) {
            source =  self.createMapItem(latitude: regionLatitude!, longtitude: regionLongitude!)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            destination  =  self.createMapItem(latitude: fromLatitude!, longtitude: fromLongitude!)
        } else {
            // Fallback on earlier versions
        }
        
        
        getPolylineRoute(from: CLLocationCoordinate2D(latitude: fromLatitude!, longitude: fromLongitude!), to: CLLocationCoordinate2D(latitude: regionLatitude!, longitude: regionLongitude!))
        
        self.getDirections(source: source, destination: destination)
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rotateMe), userInfo: nil, repeats: true)
        
    }
    
    
    func displayRegionIncomeLevel(lattitudeMQtt : Double , longtitudeMQTT : Double){
        
        
       
      
        var annotationView:MKPinAnnotationView!
        var pointAnnoation:CustomPointAnnotation!
            pointAnnoation = CustomPointAnnotation()
            if destinationAnnotation == true{
                pointAnnoation.pinCustomImageName = "destinationmark"
                 pointAnnoation.title = destinationLocation
                 
                destinationAnnotation = false
            }else if sourceAnnotation == true
            {
                pointAnnoation.pinCustomImageName = "fromlocation"
                pointAnnoation.title = destinationLocation
                sourceAnnotation = false
            }
            else{
                pointAnnoation.pinCustomImageName = "caricon"
                
                let geodesicPolyline = MKGeodesicPolyline(coordinates: &self.points, count: self.points.count)
                
                self.mapView.add(geodesicPolyline)
            }
            //3
            pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: lattitudeMQtt, longitude: longtitudeMQTT)
           // pointAnnoation.title = obj["name"] as? String
           // pointAnnoation.subtitle = obj["capitalCity"] as? String
            annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
            self.mapView.addAnnotation(annotationView.annotation!)
        
        
        
      //  }
    }
    
    
    
    func sortButtonClicked(_ sender : AnyObject){
        
    }
    func poptoPreviousScreen(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func backToDashbaord(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }
    func subscribeTopic() {
        let iotDataManager = AWSIoTDataManager.default()
        
        iotDataManager.subscribe(toTopic: "ak-012179919676-us-east-1_zI0af0OBy-shipmentTracking", qoS: .messageDeliveryAttemptedAtMostOnce, messageCallback: {
            (payload) ->Void in
            
            let jsonObj = JSON(data: (payload as NSData!) as Data)
           
            let sensors = jsonObj["sensors"].dictionaryValue
            
            let shipments = sensors["shipment"]?.dictionaryValue
            
            let shipmentId = shipments!["id"]?.stringValue

            
            if shipmentId != self.shipmentID
            {
                return
            }
           
            let locationdetails = jsonObj["location"].dictionaryValue
            let coordinates =  locationdetails["coordinates"]?.arrayValue
            
            print(coordinates![0].doubleValue)
            print(coordinates![0].doubleValue)
            let latitude = coordinates![1].doubleValue
            let longtitude = coordinates![0].doubleValue
            self.destinationAnnotation = false
            self.sourceAnnotation = false
            
            
            
            let annotation = Station(latitude: latitude, longitude: longtitude)
            
            self.annotations.append(annotation)
            
            DispatchQueue.main.async {
                self.points.removeAll()
                self.points.append((self.lastCoordinates?.coordinate)!)
                self.points.append(annotation.coordinate)
                var source : MKMapItem!
                var destination : MKMapItem!
                if #available(iOS 10.0, *) {
                  source =  self.createMapItem(latitude: latitude, longtitude: longtitude)
                } else {
                    // Fallback on earlier versions
                }
                if #available(iOS 10.0, *) {
                   destination  =  self.createMapItem(latitude: latitude, longtitude: longtitude)
                } else {
                    // Fallback on earlier versions
                }
                
                self.getDirections(source: source, destination: destination)
                self.lastCoordinates = annotation
                self.displayRegionIncomeLevel(lattitudeMQtt: latitude, longtitudeMQTT: longtitude)
                self.updateMapForCoordinate(coordinate: annotation.coordinate)
                
                
                
//                 self.mapView.addAnnotations(self.annotations)
//
//                  self.points.append(annotation.coordinate)
////                  let polyline = MKPolyline(coordinates: &self.points, count: self.points.count)
////
////                  self.mapView.add(polyline)
//
//                let geodesicPolyline = MKGeodesicPolyline(coordinates: &self.points, count: self.points.count)
//
//                self.mapView.add(geodesicPolyline)
//
//                self.updateMapForCoordinate(coordinate: annotation.coordinate)
                
            }
        } )
    }
    
    @available(iOS 10.0, *)
    func createMapItem(latitude : Double , longtitude : Double) -> MKMapItem {
        let placeMark = MKPlacemark.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longtitude))
        let mapItem = MKMapItem.init(placemark: placeMark)
        return mapItem
    }
    
    
    // Pass your source and destination coordinates in this method.
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
      // let url = NSURL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
      
        let url = NSURL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        
        
        let request = URLRequest(url:url as URL)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if error == nil {
                 print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                                        
                    OperationQueue.main.addOperation({
                        for route in routes
                        {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
//                            let path = GMSPath.init(fromEncodedPath: points! as! String)
//                            let polyline = GMSPolyline.init(path: path)
//                            polyline.strokeWidth = 3
//
//                            let bounds = GMSCoordinateBounds(path: path!)
//                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
//
//                            polyline.map = self.mapView
                            
                        }
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }
        
        
    }
    
    
    func getDirections(source : MKMapItem , destination : MKMapItem){


//       let placeMark = MKPlacemark.init(coordinate: CLLocationCoordinate2D(latitude: 10.30, longitude: 44.34))
//       let mapItem = MKMapItem.init(placemark: placeMark)

       // MKMapItem; *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
      //  [mapItem, setName:@"Name of your location"];
       
        
        let request:MKDirectionsRequest = MKDirectionsRequest()

        // source and destination are the relevant MKMapItems
       // let source = MKMapItem.forCurrentLocation()
        request.source = source
        request.destination = destination

        // Specify the transportation type
        request.transportType = MKDirectionsTransportType.automobile;

        // If you're open to getting more than one route,
        // requestsAlternateRoutes = true; else requestsAlternateRoutes = false;
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else {
                print(error)
                return }
            
            for route in unwrappedResponse.routes {
                self.mapView.add(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
        
        
//        directions.calculate (completionHandler: {
//            (response: MKDirectionsResponse?, error: NSError?) in
//
//            guard let unwrappedResponse = response else { return }
//
//            if (unwrappedResponse.routes.count > 0) {
//                self.mapView.add(unwrappedResponse.routes[0].polyline)
//                self.mapView.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
//            }
////            if error == nil {
////                self.directionsResponse = response
////                // Get whichever currentRoute you'd like, ex. 0
////                self.route = directionsResponse.routes[currentRoute] as MKRoute
////            }
//            } as! MKDirectionsHandler)
    }
    
    
    
    func updateMapForCoordinate(coordinate: CLLocationCoordinate2D) {
        let camera = MKMapCamera.init(lookingAtCenter: coordinate, fromDistance: 1000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: false)
        var center = coordinate;
        center.latitude -= self.mapView.region.span.latitudeDelta / 6.0;
        mapView.setCenter(center, animated: false);
    }
    func rotateMe() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.onHeadingUpdate = { [weak self] (data: String) in
           let headingAngle = Double(data)
            self?.userPinView?.transform = CGAffineTransform( rotationAngle: CGFloat( (Double(headingAngle!) / 360.0) * M_PI ) )

        }
       // angle = angle + 10
        
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    
    func mapView(_ mapView: MKMapView!,
                 viewFor annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MKUserLocation {
            let pin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = UIImage(named: "caricon")
            userPinView = pin
            return pin
        }
//        let pin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//        pin.image = UIImage(named: "caricon")
//        userPinView = pin
//        return pin
        
        
        
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
           // pinView!.canShowCallout = false
           // pinView!.image = UIImage(named:"caricon")!

        }
        else {
            pinView!.annotation = annotation
        }
        let customPointAnnotation = annotation as! CustomPointAnnotation
        pinView!.image = UIImage(named:customPointAnnotation.pinCustomImageName)
        return pinView
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func zoomToRegion() {
        
        let location = CLLocationCoordinate2D(latitude: 13.03297, longitude: 80.26518)
        
        let region = MKCoordinateRegionMakeWithDistance(location, 5000.0, 7000.0)
        
        mapView.setRegion(region, animated: true)
    }
    
    //MARK:- Annotations
    
    func getMapAnnotations() -> [Station] {
        var annotations:Array = [Station]()
        
        //load plist file
        
        var stations: NSArray?
        if let path = Bundle.main.path(forResource: "stations", ofType: "plist") {
            stations = NSArray(contentsOfFile: path)
        }
        if let items = stations {
            for item in items {
                let lat = (item as AnyObject).value(forKey: "lat") as! Double
                let long = (item as AnyObject).value(forKey: "long")as! Double
                let annotation = Station(latitude: lat, longitude: long)
                annotation.title = (item as AnyObject).value(forKey: "title") as? String
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
    
    //MARK:- MapViewDelegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 5
            
        }
        return polylineRenderer
    }
    

}


class Station: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude:Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}


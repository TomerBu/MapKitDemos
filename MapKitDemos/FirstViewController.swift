//
//  FirstViewController.swift
//  MapKitDemos
//
//  Created by Tomer Buzaglo on 27/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation





class FirstViewController: UIViewController {
@IBOutlet weak var map: MKMapView!
let locationManager = CLLocationManager()
var geoCoder:CLGeocoder = CLGeocoder()
override func viewDidLoad() {
    super.viewDidLoad()
    
    
    setupLocationManager()
    locationManager.requestAlwaysAuthorization()
    
    //typedef to double!
    
    map.delegate = self
    map.showsUserLocation = true
    
}

func openDirections(address: String){
    geoCoder.geocodeAddressString(address) { (places, err) in
        guard let place = places?.first else {return}
        let destPlaceMark = MKPlacemark(placemark: place)
        
        let destMapItem = MKMapItem(placemark: destPlaceMark)
        
        
        let startMapItem = MKMapItem.forCurrentLocation()
        
        
        let directionsRequest = MKDirectionsRequest() //MapKitDirectionRequest()
        directionsRequest.transportType = .walking
        directionsRequest.source = startMapItem
        directionsRequest.destination = destMapItem
        directionsRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate(completionHandler: { (response, err) in
            guard let route = response?.routes.first else{return}
            for step in route.steps{
                print(step.instructions)
            }
        })
    }
}

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //A) get the point in MapViews coordinate system
    if let point = touches.first?.location(in: map){
        //B)get the coordinates using mapView's
        //  instance method: convertPoint(p, toCoordinateFromView)
        let location = map.convert(point, toCoordinateFrom: nil)
        print(location)
        localRequest()
    }
}

func localRequest(){
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = "restaurants"
    request.region =  map.region /*more specific search:
     
     MKCoordinateRegionMakeWithDistance(locationManager.location!.coordinate, 1000, 1000)*/
    let search = MKLocalSearch(request: request)
    search.start { response, error  in
        
        //No Response
        if error != nil || response == nil{
            print("Error occured in search: \(error?.localizedDescription)")
        } else if response?.mapItems.count == 0 {
            //No Place Mathches for the query
            print("No matches found")
        } else {
            //Show time:
            print("Matches found")
            let mapItems = response!.mapItems
            for item in mapItems {
                print("Name = \(item.name)")
                print("Phone = \(item.phoneNumber)")
                print(item.placemark.addressDictionary?["Street"])
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.map.addAnnotation(annotation)
            }
        }
    }
}

@IBAction func revealRegionDetailsWithLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
    
    let touchLocation = sender.location(in: map)
    
    //convert touches to coordinates:
    let locationCoordinate = map.convert(touchLocation,
                                         toCoordinateFrom: map)
    
    print("Tapped at LatLong: ",
          "\(locationCoordinate.latitude),\(locationCoordinate.longitude)")
}


override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == UIEventSubtype.motionShake{
        guard  let location = locationManager.location else {return}
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (places, err) in
            guard let place = places?.first else{return}
            
            let dictResult = place.addressDictionary ?? [:]
            
            DispatchQueue.main.async {
                if let addressLines = dictResult["FormattedAddressLines"] as? [String]{
                    let first = addressLines[0]
                    self.openDirections(address: first)
                    let pizza = PizzaAnnotation(coordinate: location.coordinate, title: first + " Pizza", subtitle: "Wow!")
                    
                    self.map.addAnnotation(pizza)
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
                    self.map.setRegion(region, animated: true)
                    
                }
            }
        })
    }
}






@IBAction func mapChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex{
    case 0:
        map.mapType = .standard
    case 1:
        map.mapType = .hybrid
    case 2:
        map.mapType = .hybridFlyover
    case 3:
        map.mapType = MKMapType.satellite
    case 4:
        map.mapType = MKMapType.satelliteFlyover
    default: break
    }
}

func hasPermission() ->Bool{
    var isAuthorized = false
    if CLLocationManager.locationServicesEnabled(){
        let status = CLLocationManager.authorizationStatus()
        
        if  status == .notDetermined{
            print("Undetermined")
        }
        else if status == .authorizedWhenInUse || status == .authorizedAlways{
            print("Authorized")
            isAuthorized = true
        }
        else{
            print("Go to settings to allow the app access")
        }
    }
    return isAuthorized
}
var once = true
}

extension FirstViewController : CLLocationManagerDelegate{

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //  print(locations)
    //        let region = MKCoordinateRegionMakeWithDistance(locations[0].coordinate, 100, 100)
    //        let r = MKCoordinateRegion(center: locations[0].coordinate, span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
    //
    //        if once{
    //        map.setRegion(r, animated: true)
    //            once = !once
    //        }
    //
}


func setupLocationUpdates(){
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    locationManager.distanceFilter =  kCLDistanceFilterNone //10.0
    locationManager.startUpdatingLocation()
    map.showsUserLocation = true
    
}

func setupLocationManager(){
    locationManager.delegate = self
    //request for permissions
    locationManager.requestWhenInUseAuthorization()
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
}

func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse{
        setupLocationUpdates()
    }
}




func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error.localizedDescription)
}
}

extension FirstViewController : MKMapViewDelegate{
func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    //
}
func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    //
}
func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let region = MKCoordinateRegionMakeWithDistance(
        userLocation.coordinate, 500, 500)
    
    mapView.setRegion(region, animated: true)
}

//func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//    // not a pin-> Shows user’s location, don’t want to change it
//    if annotation is MKUserLocation { return nil}
//
//    //simple and inefficient
//    let pin = MKPinAnnotationView()
//    pin.pinTintColor = UIColor.orange
//    return pin
//}
//

// MARK: - MapView Delegate
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    if !(annotation is PizzaAnnotation) {return nil}
    
    var view = map.dequeueReusableAnnotationView(withIdentifier: "pizza")
    
    //initilize the view
    if view == nil{
        view = PizzaAnnotationView(annotation: annotation, reuseIdentifier: "pizza")
    }
    
    return view
}
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    return MKOverlayPathRenderer()
}

func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
             calloutAccessoryControlTapped control: UIControl) {
    print("Tapped")
}
}


extension UIImage{
func imageWithSize(size:CGSize) -> UIImage{
    var scaledImageRect = CGRect.zero
    
    scaledImageRect.size.width = size.width
    scaledImageRect.size.height = size.height
    scaledImageRect.origin.x = 0
    scaledImageRect.origin.y = 0
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    
    self.draw(in: scaledImageRect)
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
}
}

//extension UIWindow {
//    override open func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
//        super.motionBegan(motion, with: event)
//
//        guard motion == UIEventSubtype.motionShake else {
//            return
//        }
//
//        // Shake is detected
//        print("Shake!!")
//    }
//}

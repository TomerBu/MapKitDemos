//
//  PizzaAnnotation.swift
//  MapKitDemos
//
//  Created by Tomer Buzaglo on 27/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//



import UIKit
import MapKit


class PizzaAnnotation: NSObject, MKAnnotation {
    // Center latitude and longitude of the annotation view.
    // The implementation of this property must be KVO compliant. hence NSObject.
    var coordinate: CLLocationCoordinate2D
    
    // Title and subtitle for use by selection UI.
    var title: String?
    var subtitle: String?
    init(coordinate: CLLocationCoordinate2D, title: String?,subtitle: String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

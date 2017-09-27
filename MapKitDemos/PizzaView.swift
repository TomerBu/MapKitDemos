//
//  PizzaView.swift
//  MapKitDemos
//
//  Created by Tomer Buzaglo on 27/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import MapKit

class PizzaAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame.size = CGSize(width: 50,height: 50)
        self.backgroundColor = UIColor.clear
        self.canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let image = #imageLiteral(resourceName: "icons8-pizza")
        image.draw(in: rect)
    }
}

//
//  MZLocation.swift
//  Pods
//
//  Created by Michal Ziman on 26/07/2017.
//
//

import UIKit
import MapKit

public class MZLocation: NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var name: String?
    public var address: String?
    
    init(coordinate: CLLocationCoordinate2D, name: String? = nil, address: String? = nil) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
    }
}

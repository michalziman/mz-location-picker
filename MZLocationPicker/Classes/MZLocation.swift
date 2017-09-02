//
//  MZLocation.swift
//  Pods
//
//  Created by Michal Ziman on 26/07/2017.
//
//

import UIKit
import MapKit

/// Class containing coordinates and, if available, address and name of location
public class MZLocation: NSObject, MKAnnotation {
    
    /// Coordinates of location - always present.
    public var coordinate: CLLocationCoordinate2D
    
    /// Name of location - present sometimes
    public var name: String?
    
    /// HUman readable address of location - precision is variable, is present when connection to internet is available for geocoding
    public var address: String?
    
    init(coordinate: CLLocationCoordinate2D, name: String? = nil, address: String? = nil) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
    }
}

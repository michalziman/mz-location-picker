//
//  MZLocationPickerControllerActions.swift
//  Pods
//
//  Created by Michal Ziman on 03/09/2017.
//
//

import UIKit
import CoreLocation
import MapKit

extension MZLocationPickerController {
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    func cancelPicking(_ sender: Any) {
        if let d = delegate {
            d.locationPickerDidCancelPicking(self)
        }
        dismiss(animated: true)
    }
    
    func confirmPicking(_ sender: Any) {
        if let d = delegate, let loc = location {
            historyTableController.save(location: loc)
            d.locationPicker(self, didPickLocation: loc)
        }
        dismiss(animated: true)
    }
    
    func tapSelectedLocation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            let point = gestureRecognizer.location(in: locationPickerView.mapView)
            
            var tapOnCompass = false
            var tapOnAttribution = false
            for subview in locationPickerView.mapView.subviews {
                if String(describing: type(of: subview)) == "MKAttributionLabel" {
                    tapOnAttribution = subview.frame.contains(point)
                }
                if String(describing: type(of: subview)) == "MKCompassView" {
                    if #available(iOS 9.0, *) {
                        tapOnCompass = locationPickerView.mapView.showsCompass && subview.frame.contains(point)
                    } else {
                        tapOnCompass = subview.frame.contains(point)
                    }
                }
            }
            
            if !tapOnCompass && !tapOnAttribution {
                selectOnCoordinates(locationPickerView.mapView.convert(point, toCoordinateFrom: locationPickerView.mapView))
            }
        }
    }
    
    func selectOnCoordinates(_ coordinates: CLLocationCoordinate2D) {
        hideKeyboard()
        
        let cl = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        location = MZLocation(coordinate: coordinates)
        locationPickerView.chosenLocation = cl
        
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(cl) { response, error in
            if let e = error as? CLError, e.code != .geocodeCanceled {
                NSLog("MZLocationPicker:MZLocationPickerController:\(#function): \(e)")
                self.locationPickerView.chosenLocationName = coordinates.formattedCoordinates
                self.location = MZLocation(coordinate: coordinates)
            } else if let placemark = response?.first {
                let name = placemark.areasOfInterest?.first
                let address = placemark.address
                self.location = MZLocation(coordinate: coordinates, name: name, address: address)
                if let a = address, !a.isEmpty {
                    self.locationPickerView.chosenLocationName = a
                } else {
                    self.locationPickerView.chosenLocationName = coordinates.formattedCoordinates
                }
            } else {
                self.locationPickerView.chosenLocationName = coordinates.formattedCoordinates
                self.location = MZLocation(coordinate: coordinates)
            }
        }
    }
}

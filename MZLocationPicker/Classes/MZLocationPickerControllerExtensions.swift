//
//  MZLocationPickerControllerExtensions.swift
//  Pods
//
//  Created by Michal Ziman on 03/09/2017.
//
//

import UIKit
import CoreLocation
import MapKit

extension MZLocationPickerController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MZLocationPickerController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.userTrackingMode == .follow || mapView.userTrackingMode == .followWithHeading {
            selectOnCoordinates(mapView.userLocation.coordinate)
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        hideKeyboard()
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView: MKAnnotationView
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            if let image = self.annotation.image {
                annotationView.image = image
            } else {
                let tc = tintColor ?? locationPickerView.tintColor ?? annotationView.tintColor ?? .blue
                annotationView.image = UIImage(named: "pin_filled", in: Bundle(for: type(of:self)), compatibleWith: nil)?.tint(with: tc)
            }
            
            if let annotationImageOffset = self.annotation.centerOffset {
                annotationView.centerOffset = annotationImageOffset
            } else if let imageSize = annotationView.image?.size {
                annotationView.centerOffset = CGPoint(x: 0, y: -imageSize.height/2)
            }
        }
        
        return annotationView
    }
}

extension MZLocationPickerController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        locationPickerView.isShowingSearch = true
    }
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        locationPickerView.isShowingSearch = false
    }
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        locationPickerView.isShowingSearchResults = !searchText.isEmpty
        searchTableController.searchQuery = searchText
    }
}

extension MZLocationPickerController: MZLocationsTableDelegate {
    func tableController(_ tableController: MZLocationsTableController, didPickLocation location: MZLocation) {
        self.location = location
        let cl = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationPickerView.chosenLocation = cl
        if let a = location.address, !a.isEmpty {
            locationPickerView.chosenLocationName = a
        } else {
            locationPickerView.chosenLocationName = location.coordinate.formattedCoordinates
        }
        locationPickerView.mapView.setCenter(location.coordinate, animated: true)
        hideKeyboard()
    }
}

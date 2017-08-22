//
//  MZLocationPickerController.swift
//  Pods
//
//  Created by Michal Ziman on 26/07/2017.
//
//

import UIKit
import CoreLocation
import MapKit

public protocol MZLocationPickerDelegate: class {
    func locationPickerDidCancelPicking(_ locationPicker: MZLocationPickerController)
    func locationPicker(_ locationPicker: MZLocationPickerController, didPickLocation location: MZLocation)
}

public class MZLocationPickerController: UIViewController {
    weak var locationPickerView: MZLocationPickerView!
    
    public weak var delegate: MZLocationPickerDelegate?
    public var mapType: MKMapType {
        set {
            if let lpv = locationPickerView {
                lpv.mapView.mapType = newValue
            }
        }
        get {
            if let lpv = locationPickerView {
                return lpv.mapView.mapType
            }
            return .standard
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let contentView = MZLocationPickerView(frame: view.bounds)
        locationPickerView = contentView
        view.addSubview(contentView)

        contentView.isShowingLocateMe = (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)
        
        contentView.cancelButton.target = self
        contentView.cancelButton.action = #selector(cancelPicking(_:))
        
        contentView.mapView.delegate = self
        
        let tapOnMap = UITapGestureRecognizer(target: self, action: #selector(setLocation(_:)))
        tapOnMap.delegate = self
        contentView.mapView.addGestureRecognizer(tapOnMap)
        
        let constraints = [
            NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        ]
        view.addConstraints(constraints)
        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    func cancelPicking(_ sender: Any) {
        if let d = delegate {
            d.locationPickerDidCancelPicking(self)
        }
        dismiss(animated: true)
    }
    
    func setLocation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            let point = gestureRecognizer.location(in: locationPickerView.mapView)
            let coordinates = locationPickerView.mapView.convert(point, toCoordinateFrom: locationPickerView.mapView)
            
            // add point annotation to map
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            locationPickerView.mapView.addAnnotation(annotation)
            
//            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            // remember location, get address
//            geocoder.cancelGeocode()
//            geocoder.reverseGeocodeLocation(location) { response, error in
//                if let error = error as NSError?, error.code != 10 {
//                    self.location = Location(location: location)
//                } else if let placemark = response?.first {
//                    // get POI name from placemark if any
//                    let name = placemark.areasOfInterest?.first
//                    // pass user selected location too
//                    self.location = Location(name: name, location: location, placemark: placemark)
//                }
//            }
        }
    }
}

extension MZLocationPickerController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MZLocationPickerController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.userTrackingMode == .follow || mapView.userTrackingMode == .followWithHeading {
            // TODO set pin location to user location
            print("region changed while tracked")
        }
    }
}

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
    
    let geocoder = CLGeocoder()
    var location: MZLocation? = nil
    
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
        contentView.useButton.addTarget(self, action: #selector(confirmPicking(_:)), for: .touchUpInside)
        contentView.mapView.delegate = self
        
        let tapOnMap = UITapGestureRecognizer(target: self, action: #selector(tapSelectedLocation(_:)))
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
    
    func confirmPicking(_ sender: Any) {
        if let d = delegate, let loc = location {
            d.locationPicker(self, didPickLocation: loc)
        }
        dismiss(animated: true)
    }
    
    func tapSelectedLocation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            let point = gestureRecognizer.location(in: locationPickerView.mapView)
            selectOnCoordinates(locationPickerView.mapView.convert(point, toCoordinateFrom: locationPickerView.mapView))
        }
    }
    
    func selectOnCoordinates(_ coordinates: CLLocationCoordinate2D) {
        let cl = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        location = MZLocation(coordinate: coordinates)
        locationPickerView.chosenLocation = cl
        
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(cl) { response, error in
            if let e = error as? CLError, e.code != .geocodeCanceled {
                print("MZLocationPicker:\(#function): \(e)")
                self.locationPickerView.chosenLocationLabel.text = cl.formattedCoordinates
                self.location = MZLocation(coordinate: coordinates)
            } else if let placemark = response?.first {
                let name = placemark.areasOfInterest?.first
                let address = self.getAddress(placemark: placemark)
                self.location = MZLocation(coordinate: coordinates, name: name, address: address)
                if let a = address {
                    self.locationPickerView.chosenLocationLabel.text = a
                }
            } else {
                self.locationPickerView.chosenLocationLabel.text = cl.formattedCoordinates
                self.location = MZLocation(coordinate: coordinates)
            }
            
            // Show info about chosen location
            self.locationPickerView.showChosenLocationConstraint.isActive = true
            UIView.animate(withDuration: 0.15) {
                self.locationPickerView.layoutIfNeeded()
            }
        }
    }
    
    func getAddress(placemark: CLPlacemark) -> String? {
        if let addressDict = placemark.addressDictionary {
            let lines: [String]
            if let linesFromAddressDict = addressDict["FormattedAddressLines"] as? [String] {
                lines = linesFromAddressDict
            } else {
                var street: String? = nil
                if let stf = placemark.subThoroughfare, let tf = placemark.thoroughfare {
                    street = "\(stf) \(tf)"
                } else if let stf = placemark.subThoroughfare {
                    street = stf
                } else if let tf = placemark.thoroughfare {
                    street = tf
                }
                var country: String? = nil
                if let c = placemark.country, let icc = placemark.isoCountryCode {
                    country = "\(c) \(icc)"
                } else if let c = placemark.country {
                    country = c
                } else if let icc = placemark.isoCountryCode {
                    country = icc
                }
                let linesFromPlacemark: [String?] = [street, placemark.locality, placemark.administrativeArea, placemark.postalCode, country]
                
                let disponibleLines = linesFromPlacemark.filter { line -> Bool in
                    return line != nil
                }
                lines = disponibleLines.map { line -> String in
                    return line ?? ""
                }
            }
            if lines.count > 0 {
                return lines.joined(separator: "\n")
            }
        }
        return nil
    }
    
    deinit {
        geocoder.cancelGeocode()
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
            selectOnCoordinates(mapView.userLocation.coordinate)
        }
    }
}

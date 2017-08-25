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
    fileprivate let annotationIdentifier = "MZLocationPickerCOntrollerAnnotationIdentifier"
    weak var locationPickerView: MZLocationPickerView!
    
    let geocoder = CLGeocoder()
    var location: MZLocation? = nil
    
    public struct AnnotationImage {
        public var image: UIImage? = nil
        public var centerOffset: CGPoint? = nil
    }
    public var annotation: AnnotationImage = AnnotationImage()
    
    public weak var delegate: MZLocationPickerDelegate?
    public var mapType: MKMapType = .standard {
        didSet {
            if let lpv = locationPickerView {
                lpv.mapView.mapType = mapType
            }
        }
    }
    public var tintColor: UIColor? {
        didSet {
            if let lpw = locationPickerView {
                lpw.tintColor = tintColor
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let contentView = MZLocationPickerView(frame: view.bounds)
        locationPickerView = contentView
        view.addSubview(locationPickerView)

        locationPickerView.tintColor = tintColor ?? locationPickerView.tintColor
        locationPickerView.mapView.mapType = mapType
        locationPickerView.isShowingLocateMe = (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)
        locationPickerView.cancelButton.target = self
        locationPickerView.cancelButton.action = #selector(cancelPicking(_:))
        locationPickerView.useButton.addTarget(self, action: #selector(confirmPicking(_:)), for: .touchUpInside)
        locationPickerView.mapView.delegate = self
        
        let tapOnMap = UITapGestureRecognizer(target: self, action: #selector(tapSelectedLocation(_:)))
        tapOnMap.delegate = self
        locationPickerView.mapView.addGestureRecognizer(tapOnMap)
        
        let constraints = [
            NSLayoutConstraint(item: locationPickerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: locationPickerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: locationPickerView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: locationPickerView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        ]
        view.addConstraints(constraints)
        
        locationPickerView.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        locationPickerView.searchBar.delegate = self
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
                print("MZLocationPicker:\(#function): \(e)")
                self.locationPickerView.chosenLocationName = cl.formattedCoordinates
                self.location = MZLocation(coordinate: coordinates)
            } else if let placemark = response?.first {
                let name = placemark.areasOfInterest?.first
                let address = self.getAddress(placemark: placemark)
                self.location = MZLocation(coordinate: coordinates, name: name, address: address)
                if let a = address, !a.isEmpty {
                    self.locationPickerView.chosenLocationName = a
                } else {
                    self.locationPickerView.chosenLocationName = cl.formattedCoordinates
                }
            } else {
                self.locationPickerView.chosenLocationName = cl.formattedCoordinates
                self.location = MZLocation(coordinate: coordinates)
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
        // TODO: search
    }
}

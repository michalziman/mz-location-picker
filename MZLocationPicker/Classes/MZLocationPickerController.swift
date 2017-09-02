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

public protocol MZLocationPickerTranslator: class {
    var locationPickerTitleText: String { get }
    var locationPickerCancelText: String { get }
    var locationPickerSearchText: String { get }
    var locationPickerUseText: String { get }
    var locationPickerHistoryText: String { get }
}

public class MZLocationPickerController: UIViewController {
    fileprivate let annotationIdentifier = "MZLocationPickerCOntrollerAnnotationIdentifier"
    weak var locationPickerView: MZLocationPickerView!
    let searchTableController = MZSearchTableController(style: .plain)
    let historyTableController = MZHistoryTableController(style: .plain)
    
    let geocoder = CLGeocoder()
    var location: MZLocation? = nil
    
    public struct AnnotationImage {
        public var image: UIImage? = nil
        public var centerOffset: CGPoint? = nil
    }
    public var annotation: AnnotationImage = AnnotationImage()
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
    
    public weak var delegate: MZLocationPickerDelegate?
    public weak var translator: MZLocationPickerTranslator? {
        didSet {
            if let t = translator, let lpw = locationPickerView {
                lpw.setTranslations(from: t)
                historyTableController.headerTitle = t.locationPickerHistoryText
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
        if let t = translator {
            locationPickerView.setTranslations(from: t)
            historyTableController.headerTitle = t.locationPickerHistoryText
        }
        
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
        
        locationPickerView.searchResultsView = searchTableController.tableView
        searchTableController.delegate = self
        
        locationPickerView.recentLocationsView = historyTableController.tableView
        historyTableController.delegate = self
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

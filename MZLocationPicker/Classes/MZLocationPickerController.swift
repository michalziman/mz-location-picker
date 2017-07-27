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
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelPicking(_ sender: Any) {
        if let d = delegate {
            d.locationPickerDidCancelPicking(self)
        }
        dismiss(animated: true)
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

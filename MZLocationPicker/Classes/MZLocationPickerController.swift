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

/// The object to be notified about picked location or when location picking is cancelled
public protocol MZLocationPickerDelegate: class {
    
    /**
     Called when location picking is cancelled.
     - parameter locationPicker: Location picker in which picking was cancelled
     */
    func locationPickerDidCancelPicking(_ locationPicker: MZLocationPickerController)
    
    /**
     Called when location is picked.
     - parameter locationPicker: Location picker in which location was picked
     - parameter location: Location that was picked (as MZLocation, so it also carries name and human readable address)
     */
    func locationPicker(_ locationPicker: MZLocationPickerController, didPickLocation location: MZLocation)
}

/// The object from which custom texts (translations) are requested
public protocol MZLocationPickerTranslator: class {
    
    /// Custom text for title (Location)
    var locationPickerTitleText: String { get }
    
    /// Custom text for Cancel button
    var locationPickerCancelText: String { get }
    
    /// Custom text for Searchbar placeholder
    var locationPickerSearchText: String { get }
    
    /// Custom text for Use button
    var locationPickerUseText: String { get }
    
    /// Custom text for History header title
    var locationPickerHistoryText: String { get }
    
    /// Custom text for Delete location from history (on swipe row left in history table)
    var locationPickerDeleteText: String { get }
}

/**
 Main class of MZLocationPicker. By presenting this controller (preferably modally) the location picker is shown to user.

 Settable members:
  - annotation.image: Image for custom annotation/pin
  - annotation.centerOffset: Offsetof center for custom annotation/pin image
  - mapType: MKMapType - recommended: standard, satelite, hybrid. There is known bug with flyover map types
  - tintColor: Color for controls and annotation/pin, if no annotation.image is used, or if annotation.image is template matching tint color
  - delegate: Object, which will be notified of chosen location or picking cancelation. It is strongly recommended to set one
  - translator: Object, which provides custom text, usually NSLocalizedString-s
 */
public class MZLocationPickerController: UIViewController {
    let annotationIdentifier = "MZLocationPickerControllerAnnotationIdentifier"
    weak var locationPickerView: MZLocationPickerView!
    let searchTableController = MZSearchTableController(style: .plain)
    let historyTableController = MZHistoryTableController(style: .plain)
    
    let geocoder = CLGeocoder()
    var location: MZLocation? = nil
    
    /**
     This struct groups together custom annotation/pin informations
     
     Settable members:
     - image: Image for custom annotation/pin
     - centerOffset: Offsetof center for custom annotation/pin image
    */
    public struct AnnotationImage {
        /// Image for custom annotation/pin
        public var image: UIImage? = nil
        /// Offsetof center for custom annotation/pin image
        public var centerOffset: CGPoint? = nil
    }
    
    /**
     Custom annotation/pin
     
     Settable members:
     - image: Image for custom annotation/pin
     - centerOffset: Offsetof center for custom annotation/pin image
     */
    public var annotation: AnnotationImage = AnnotationImage()
    
    /// MKMapType - recommended: standard, satelite, hybrid. There is known bug with flyover map types
    public var mapType: MKMapType = .standard {
        didSet {
            if let lpv = locationPickerView {
                lpv.mapView.mapType = mapType
            }
        }
    }
    
    /// Color for controls and annotation/pin, if no annotation.image is used, or if annotation.image is template matching tint color
    public var tintColor: UIColor? {
        didSet {
            if let lpw = locationPickerView {
                lpw.tintColor = tintColor
            }
        }
    }
    
    /// Object, which will be notified of chosen location or picking cancelation. It is strongly recommended to set one
    public weak var delegate: MZLocationPickerDelegate?
    
    /// Object, which provides custom text, usually NSLocalizedString-s
    public weak var translator: MZLocationPickerTranslator? {
        didSet {
            if let t = translator, let lpw = locationPickerView {
                lpw.setTranslations(from: t)
                historyTableController.setTranslations(from: t)
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
            historyTableController.setTranslations(from: t)
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
    
    deinit {
        geocoder.cancelGeocode()
    }
}

//
//  MZLocationPickerView.swift
//  Pods
//
//  Created by Michal Ziman on 27/07/2017.
//
//

import UIKit
import MapKit

class MZLocationPickerView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationItem: UINavigationItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var isShowingLocateMe: Bool {
        set {
            navigationItem.leftBarButtonItem = newValue ? MKUserTrackingBarButtonItem(mapView: mapView) : nil
        }
        get {
            return (navigationItem.leftBarButtonItem != nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        // Load from nib
        let nib = UINib(nibName: "LocationPickerView", bundle: Bundle(for: type(of:self)))
        nib.instantiate(withOwner: self, options: nil)
        
        contentView.frame = bounds
        addSubview(contentView)        
    }
}

//
//  MZLocationPickerView.swift
//  Pods
//
//  Created by Michal Ziman on 27/07/2017.
//
//

import UIKit
import MapKit

fileprivate struct Constants {
    static let shadowOpacity: Float = 0.3
    static let bottomShadowOffset: CGSize = CGSize(width: 0, height: -3)
    static let topShadowOffset: CGSize = CGSize(width: 0, height: 3)
    static let shadowRadius: CGFloat = 2
}

class MZLocationPickerView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationItem: UINavigationItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var chosenLocationView: UIView!
    
    @IBOutlet var showSearchConstraint: NSLayoutConstraint!
    @IBOutlet var showChosenLocationConstraint: NSLayoutConstraint!
    
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
        
        searchView.layer.masksToBounds = false
        searchView.layer.shadowColor = UIColor.black.cgColor
        searchView.layer.shadowOpacity = Constants.shadowOpacity
        searchView.layer.shadowOffset = Constants.topShadowOffset
        searchView.layer.shadowRadius = Constants.shadowRadius
        
        chosenLocationView.layer.masksToBounds = false
        chosenLocationView.layer.shadowColor = UIColor.black.cgColor
        chosenLocationView.layer.shadowOpacity = Constants.shadowOpacity
        chosenLocationView.layer.shadowOffset = Constants.bottomShadowOffset
        chosenLocationView.layer.shadowRadius = Constants.shadowRadius
        
        translatesAutoresizingMaskIntoConstraints = false
        
        showSearchConstraint.isActive = false
        showChosenLocationConstraint.isActive = false
    }
}

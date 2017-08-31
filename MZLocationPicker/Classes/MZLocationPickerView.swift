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
    static let animationDuration: TimeInterval = 0.15
}

class MZLocationPickerView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationItem: UINavigationItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cancelCrossButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var chosenLocationView: UIView!
    @IBOutlet weak var chosenLocationLabel: UILabel!
    @IBOutlet weak var useButton: UIButton!
    
    @IBOutlet var showCancelSearchConstraint: NSLayoutConstraint!
    @IBOutlet var showSearchConstraint: NSLayoutConstraint!
    @IBOutlet var showChosenLocationConstraint: NSLayoutConstraint!
    
    weak var searchResultsView: UIView? = nil {
        willSet {
            if let oldSrv = searchResultsView {
                oldSrv.removeFromSuperview()
            }
        }
        didSet {
            if let newSrv = searchResultsView {
                addToSearchView(view: newSrv)
                newSrv.isHidden = !isShowingSearchResults
            }
        }
    }
    weak var recentLocationsView: UIView? = nil {
        willSet {
            if let oldRlv = recentLocationsView {
                oldRlv.removeFromSuperview()
            }
        }
        didSet {
            if let newRlv = recentLocationsView {
                addToSearchView(view: newRlv)
                newRlv.isHidden = isShowingSearchResults
            }
        }
    }
    func addToSearchView(view:UIView) {
        var newFrame = searchView.frame
        newFrame.origin.y = searchBar.frame.height
        newFrame.size.height = searchView.frame.height - searchBar.frame.height
        view.frame = newFrame

        view.translatesAutoresizingMaskIntoConstraints = false
        searchView.addSubview(view)
        searchView.addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: searchBar, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: searchView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: searchView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: searchView, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    
    var chosenLocation: CLLocation? = nil {
        didSet {
            guard let cl = chosenLocation else {
                return
            }
            
            // Replace annotation with new one
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = cl.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    var chosenLocationName: String? = nil {
        didSet {
            chosenLocationLabel.text = chosenLocationName
            showChosenLocationConstraint.isActive = true
            UIView.animate(withDuration: Constants.animationDuration) {
                self.layoutIfNeeded()
            }
        }
    }
    var isShowingLocateMe: Bool {
        set {
            navigationItem.leftBarButtonItem = newValue ? MKUserTrackingBarButtonItem(mapView: mapView) : nil
        }
        get {
            return (navigationItem.leftBarButtonItem != nil)
        }
    }
    var isShowingSearch: Bool {
        set {
            showSearchConstraint.isActive = newValue
            showCancelSearchConstraint.isActive = newValue
            UIView.animate(withDuration: Constants.animationDuration) {
                self.layoutIfNeeded()
            }
        }
        get {
            return showSearchConstraint.isActive
        }
    }
    var isShowingSearchResults: Bool = false {
        didSet {
            if isShowingSearchResults {
                if let srv = searchResultsView {
                    srv.isHidden = false
                }
                if let rlv = recentLocationsView {
                    rlv.isHidden = true
                }
            } else {
                if let srv = searchResultsView {
                    srv.isHidden = true
                }
                if let rlv = recentLocationsView {
                    rlv.isHidden = false
                }
            }
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
        
        showCancelSearchConstraint.isActive = false
        showSearchConstraint.isActive = false
        showChosenLocationConstraint.isActive = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            showSearchConstraint.constant = keyboardRectangle.height
        }
    }
    
    func setTranslations(from tranlsator:MZLocationPickerTranslator) {
        navigationItem.title = tranlsator.locationPickerTitleText
        cancelButton.title = tranlsator.locationPickerCancelText
        searchBar.placeholder = tranlsator.locationPickerSearchText
        useButton.setTitle(tranlsator.locationPickerUseText, for: .normal)
        // TODO: set history text
    }
    
    @IBAction func hideSearch(_ sender: Any) {
        endEditing(true)
        isShowingSearch = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

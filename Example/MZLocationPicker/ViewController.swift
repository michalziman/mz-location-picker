//
//  ViewController.swift
//  MZLocationPicker
//
//  Created by Michal Ziman on 07/26/2017.
//  Copyright (c) 2017 Michal Ziman. All rights reserved.
//

import UIKit
import CoreLocation
import MZLocationPicker

class ViewController: UIViewController {
    @IBOutlet weak var chooseLocationButton: UIButton!
    @IBOutlet weak var chosenLocationLabel: UILabel!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chooseLocationCustom(_ sender: Any) {
        let picker = MZLocationPickerController()
        picker.delegate = self
        picker.tintColor = .purple
        picker.annotation.image = #imageLiteral(resourceName: "custom_pin")
        picker.annotation.centerOffset = CGPoint(x: 0, y: 24)
        if #available(iOS 9.0, *) {
            picker.mapType = .satelliteFlyover
        } else {
            picker.mapType = .satellite
        }
        picker.translator = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func chooseLocation(_ sender: Any) {
        let picker = MZLocationPickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension ViewController: MZLocationPickerDelegate {
    func locationPickerDidCancelPicking(_ locationPicker: MZLocationPickerController) {
        chosenLocationLabel.text = "Picking canceled"
    }
    func locationPicker(_ locationPicker: MZLocationPickerController, didPickLocation location: MZLocation) {
        let name: String
        if let nameFromLocation = location.name {
            name = nameFromLocation + "\n"
        } else {
            name = ""
        }
        let address: String
        if let addressFromLocation = location.address {
            address = (!name.isEmpty ? "-\n" : "") + addressFromLocation + "\n"
        } else {
            address = ""
        }
        let coordinates = "(\(location.coordinate.latitude) \(location.coordinate.longitude))"
        chosenLocationLabel.text = "Chosen location:\n" + name + address + coordinates
    }
}

extension ViewController: MZLocationPickerTranslator {
    var locationPickerUseText: String {
        get {
            return "Použiť"
        }
    }
    var locationPickerCancelText: String {
        get {
            return "Zrušiť"
        }
    }
    var locationPickerTitleText: String {
        get {
            return "Pozícia"
        }
    }
    var locationPickerSearchText: String {
        get {
            return "Hľadať"
        }
    }
    var locationPickerHistoryText: String {
        get {
            return "História"
        }
    }
}

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
            name = nameFromLocation + " "
        } else {
            name = ""
        }
        let address: String
        if let addressFromLocation = location.address {
            address = (!name.isEmpty ? "- " : "") + addressFromLocation + " "
        } else {
            address = ""
        }
        let coordinates = "(\(location.coordinate.latitude) \(location.coordinate.longitude))"
        chosenLocationLabel.text = "Chosen location: " + name + address + coordinates
    }
}

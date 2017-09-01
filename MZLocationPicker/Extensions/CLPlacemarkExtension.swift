//
//  CLselfExtension.swift
//  Pods
//
//  Created by Michal Ziman on 01/09/2017.
//
//

import Foundation
import CoreLocation

extension CLPlacemark {
    var address: String? {
        get {
            if let addressDict = self.addressDictionary {
                let lines: [String]
                if let linesFromAddressDict = addressDict["FormattedAddressLines"] as? [String] {
                    lines = linesFromAddressDict
                } else {
                    var street: String? = nil
                    if let stf = self.subThoroughfare, let tf = self.thoroughfare {
                        street = "\(stf) \(tf)"
                    } else if let stf = self.subThoroughfare {
                        street = stf
                    } else if let tf = self.thoroughfare {
                        street = tf
                    }
                    var country: String? = nil
                    if let c = self.country, let icc = self.isoCountryCode {
                        country = "\(c) \(icc)"
                    } else if let c = self.country {
                        country = c
                    } else if let icc = self.isoCountryCode {
                        country = icc
                    }
                    let linesFromPlacemark: [String?] = [street, self.locality, self.administrativeArea, self.postalCode, country]
                    
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
    }
}

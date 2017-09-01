//
//  CLLocationCoordinate2DExtension.swift
//  Pods
//
//  Created by Michal Ziman on 22/08/2017.
//
//

import CoreLocation

extension CLLocationCoordinate2D {
    var formattedCoordinates: String {
        return latitudeDegreeDescription + ", " + longitudeDegreeDescription
    }
    var latitudeDegreeDescription: String {
        return fromDecToDeg(input: self.latitude) + " \(self.latitude >= 0 ? "N" : "S")"
    }
    var longitudeDegreeDescription: String {
        return fromDecToDeg(input: self.longitude) + " \(self.longitude >= 0 ? "E" : "W")"
    }
    private func fromDecToDeg(input: Double) -> String {
        var inputSeconds = Int(input * 3600)
        let inputDegrees = inputSeconds / 3600
        inputSeconds = abs(inputSeconds % 3600)
        let inputMinutes = inputSeconds / 60
        inputSeconds %= 60
        return "\(abs(inputDegrees))°\(inputMinutes)'\(inputSeconds)''"
    }
}

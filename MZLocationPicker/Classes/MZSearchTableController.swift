//
//  MZSearchTableController.swift
//  Pods
//
//  Created by Michal Ziman on 01/09/2017.
//
//

import UIKit
import MapKit



class MZSearchTableController: MZLocationsTableController {
    private var locationSearch: MKLocalSearch?
    
    var searchQuery: String = "" {
        didSet {
            if searchQuery.isEmpty {
                results = []
                tableView.reloadData()
            } else {
                locationSearch?.cancel()
                let request = MKLocalSearchRequest()
                request.naturalLanguageQuery = searchQuery
                let newLocationSearch = MKLocalSearch(request: request)
                locationSearch = newLocationSearch
                let oldQuery = searchQuery
                newLocationSearch.start { (response, error) in
                    DispatchQueue.main.async {
                        if let r = response {
                            if self.searchQuery != oldQuery {
                                return
                            }
                            self.results = r.mapItems.map { mapItem -> MZLocation in
                                let placemark = mapItem.placemark
                                return MZLocation(coordinate: placemark.coordinate, name: mapItem.name, address: placemark.address)
                            }
                            self.tableView.reloadData()
                        } else {
                            NSLog("MZLocationPicker:MZSearchTableController:\(#function): \(String(describing: error))")
                        }
                    }
                }
            }
        }
    }
}

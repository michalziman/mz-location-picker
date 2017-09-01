//
//  MZSearchTableController.swift
//  Pods
//
//  Created by Michal Ziman on 01/09/2017.
//
//

import UIKit
import MapKit

protocol MZSearchTableDelegate: class {
    func searchTableController(_ searchTableController:MZSearchTableController, didPickLocation location:MZLocation)
}

class MZSearchTableController: UITableViewController {
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
                            print("MZSearchTableController:\(#function): \(String(describing: error))")
                        }
                    }
                }
            }
        }
    }

    private var results: [MZLocation] = []
    
    weak var delegate: MZSearchTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        let cell = dequeuedCell ?? UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        cell.selectionStyle = .none
        let location = results[indexPath.row]
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.address?.replacingOccurrences(of: "\n", with: ", ")
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let d = delegate {
            d.searchTableController(self, didPickLocation: results[indexPath.row])
        }
    }

}

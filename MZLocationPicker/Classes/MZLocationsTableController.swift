//
//  MZLocationsTableController.swift
//  Pods
//
//  Created by Michal Ziman on 02/09/2017.
//
//

import UIKit

protocol MZLocationsTableDelegate: class {
    func tableController(_ tableController:MZLocationsTableController, didPickLocation location:MZLocation)
}

class MZLocationsTableController: UITableViewController {
    var results: [MZLocation] = []
    
    weak var delegate: MZLocationsTableDelegate?
    
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
        if let name = location.name {
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = location.address?.replacingOccurrences(of: "\n", with: ", ")
        } else if let address = location.address {
            cell.textLabel?.text = address.replacingOccurrences(of: "\n", with: ", ")
        } else {
            cell.textLabel?.text = location.coordinate.formattedCoordinates
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let d = delegate {
            d.tableController(self, didPickLocation: results[indexPath.row])
        }
    }
}

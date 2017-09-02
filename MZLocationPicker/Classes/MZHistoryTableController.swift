//
//  MZHistoryTableController.swift
//  Pods
//
//  Created by Michal Ziman on 02/09/2017.
//
//

import UIKit
import CoreData
import CoreLocation

class MZHistoryTableController: MZLocationsTableController {
    var headerTitle: String = "History"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let context = managedObjectContext else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MZRecentLocation")
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetched = try context.fetch(fetchRequest) as? [MZRecentLocation] ?? []
            results = fetched.map({ recentLocation -> MZLocation in
                return MZLocation(coordinate: CLLocationCoordinate2D(latitude: recentLocation.latitude,
                                                                     longitude: recentLocation.longitude),
                                  name: recentLocation.name,
                                  address: recentLocation.address)
            })
        } catch let error as NSError {
            print("MZLocationPicker:MZHistoryTableController:\(#function):ModelError: Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle
    }
    
    
    
    
    // MARK: - Core Data
    
    lazy var databaseDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[urls.count-1]
        let dbDirectory = documentsDirectory.appendingPathComponent("MZLocationPickerHistory")
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: dbDirectory.path) {
            try? FileManager.default.createDirectory(at: dbDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return dbDirectory
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: type(of:self)).url(forResource: "MZLocationPickerHistory", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.databaseDirectory.appendingPathComponent("MZLocationPickerHistory.sqlite")
        var failureReason = "There was an error creating or loading the MZLocationPickerHistory saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true])
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the MZLocationPickerHistory saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "MZLocationPickerError", code: 9999, userInfo: dict)
            NSLog("MZLocationPicker:MZHistoryTableController:\(#function) \(wrappedError), \(wrappedError.userInfo)")
            return nil
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Adding Location support
    
    func save(location: MZLocation) {
        guard let context = managedObjectContext else {
            NSLog("MZLocationPicker:MZHistoryTableController:\(#function) Could not save location to history due to missing managed object context.")
            return
        }
        let entityDescription = NSEntityDescription.entity(forEntityName: "MZRecentLocation",
                                              in:context)!
        let recentLocation = MZRecentLocation(entity: entityDescription, insertInto: context)
        recentLocation.address = location.address
        recentLocation.name = location.name
        recentLocation.date = Date() as NSDate
        recentLocation.latitude = location.coordinate.latitude
        recentLocation.longitude = location.coordinate.longitude
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            NSLog("MZLocationPicker:MZHistoryTableController:\(#function) \(nserror), \(nserror.userInfo)")
        }
    }
}

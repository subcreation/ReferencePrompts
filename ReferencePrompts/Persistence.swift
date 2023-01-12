//
//  Persistence.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/10/23.
//
import Foundation
import CloudKit
import CoreData
import CoreLocation

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "ReferencePrompts")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        do {
            try container.viewContext.save()
        } catch {
            print("Error saving to CoreData: ", error.localizedDescription)
        }
    }
}

//
//  CoreDataManager.swift
//  Data
//
//  Created by 김영훈 on 1/4/25.
//

import CoreData

public class CoreDataManager {
    public static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Location")
        container.loadPersistentStores { _, error in
            if let error = error {
                
            }
        }
        return container
    }()
    
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
}

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
        let modelName = "Model"
            guard let modelURL = Bundle(for: CoreDataManager.self).url(forResource: modelName, withExtension: "momd"),
                  let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Failed to locate Core Data model")
            }

            let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("Failed to load persistent store: \(error)")
                }
            }
            return container
    }()
    
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
}

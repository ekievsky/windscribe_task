//
//  PersistencyService.swift
//  VPNConnector
//
//  Created by Yevhen Kyivskyi on 12.07.2021.
//

import CoreData

protocol PersistencyServicing {
    var backgroundContext: NSManagedObjectContext { get }
    
    func fetchObject<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) throws -> [T]
}

class PersistensyService: PersistencyServicing {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    var backgroundContext: NSManagedObjectContext {
        return coreDataStack.backgroundContext
    }
    
    func fetchObject<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) throws -> [T] {
        let models = try coreDataStack.viewContext.fetch(fetchRequest)
        return models
    }
}

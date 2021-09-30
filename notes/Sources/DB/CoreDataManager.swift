import CoreData

class CoreDataManager {
  
  private let containerName: String
  
  init(containerName: String) {
    self.containerName = containerName
  }
  
  private(set) lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: containerName)
    
    container
      .loadPersistentStores { _, error in
        if let error = error {
          fatalError("Unresolved error: \(error.localizedDescription)")
        }
      }
    
    return container
  }()
  
  lazy private(set) var backgroundContext: NSManagedObjectContext = {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.shouldDeleteInaccessibleFaults = true
    return context
  }()
  
  lazy private(set) var viewContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.parent = backgroundContext
    context.automaticallyMergesChangesFromParent = true
    return context
  }()
}

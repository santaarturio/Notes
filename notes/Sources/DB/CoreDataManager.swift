import CoreData

final class CoreDataManager {
  
  static let instance = CoreDataManager()
  
  private init() { }
  
  private(set) lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "NotesData")
    
    container
      .loadPersistentStores { _, error in
        if let error = error {
          fatalError("Unresolved error: \(error.localizedDescription)")
        }
      }
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    return container
  }()
  
  var viewContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  lazy private(set) var backgroundContext: NSManagedObjectContext = {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.shouldDeleteInaccessibleFaults = true
    return context
  }()
}

extension CoreDataManager {
  
  func saveViewContext() {
    if viewContext.hasChanges {
      do {
        try viewContext.save()
      } catch {
        print("Error occured while save view context: \(error.localizedDescription)")
      }
    }
  }
  
  func saveBackgroundContext() {
    backgroundContext
      .perform { [unowned self] in
        if backgroundContext.hasChanges {
          do {
            try backgroundContext.save()
          } catch {
            print("Error occured while save background context: \(error.localizedDescription)")
          }
        }
      }
  }
  
  func removeAll(entities type: NSManagedObject.Type) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    backgroundContext
      .perform { [unowned self] in
        do {
          try backgroundContext.execute(deleteRequest)
          try backgroundContext.save()
        } catch {
          print("Error occured while delete entities of type \(type): \(error.localizedDescription)")
        }
      }
  }
}

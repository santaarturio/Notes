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
  
  func saveContext() {
    if viewContext.hasChanges {
      do {
        try viewContext.save()
      } catch {
        print("Error occured while save view context: \(error.localizedDescription)")
      }
    }
  }
  
  func saveBackgroundContext() {
    if backgroundContext.hasChanges {
      do {
        try backgroundContext.save()
      } catch {
        print("Error occured while save background context: \(error.localizedDescription)")
      }
    }
  }
  
  func removeAll(entity: NSManagedObject.Type) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entity))
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try viewContext.execute(deleteRequest)
      try viewContext.save()
    } catch { print(error) }
  }
}

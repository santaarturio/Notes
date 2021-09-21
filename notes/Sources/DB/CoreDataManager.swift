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
    
    return container
  }()
  
  var viewContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  func saveContext() {
    if viewContext.hasChanges {
      do {
        try viewContext.save()
      } catch {
        print("Error occured while save context: \(error.localizedDescription)")
      }
    }
  }
  
  func removeAll(entity: NSManagedObject.Type) {
    let fetchRequest = entity.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try viewContext.execute(deleteRequest)
    } catch { print(error) }
  }
}

import CoreData

class CoreDataManager {
  
  private let containerName: String
  
  init(containerName: String) { self.containerName = containerName }
  
  lazy private var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: containerName)
    
    container
      .loadPersistentStores { _, error in
        if let error = error {
          fatalError("Unresolved error while loading Persistent Store: \(error.localizedDescription)")
        }
      }
    
    return container
  }()
  
  lazy private var backgroundContext: NSManagedObjectContext = {
    persistentContainer.newBackgroundContext()
  }()
  
  lazy private(set) var viewContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.parent = backgroundContext
    return context
  }()
}

// MARK: - Save
extension CoreDataManager {
  
  func save(context: NSManagedObjectContext) {
    context.perform {
      if context.hasChanges {
        do {
          try context.save()
        } catch {
          print("Error occured while saving context: \(error.localizedDescription)")
        }
      }
    }
  }
  
  func save() {
    viewContext.perform { [unowned self] in
      do {
        if viewContext.hasChanges { try viewContext.save() }
      } catch {
        print("Unable to Save Changes of VIew Context\n", error.localizedDescription)
      }
      
      backgroundContext.perform { [unowned self] in
        do {
          if backgroundContext.hasChanges { try backgroundContext.save() }
        } catch {
          print("Unable to Save Changes of Background Context\n", error.localizedDescription)
        }
      }
    }
  }
}

// MARK: - Remove
extension CoreDataManager {
  
  func removeAllEntities(named entityName: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try backgroundContext
        .execute(deleteRequest)
    } catch {
      print("Error occured while delete entities named \(entityName)\n", error.localizedDescription)
    }
  }
}

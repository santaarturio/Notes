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

extension CoreDataManager: NotesDataBaseProtocol {
  static let shared: NotesDataBaseProtocol = CoreDataManager(containerName: "NotesData")
  
  func create(configurations configure: @escaping (Note) -> Void) {
    backgroundContext.perform { [unowned self] in
      configure(Note(context: backgroundContext))
    }
  }
  
  func syncUnsynced(notesAPI: NotesAPIProtocol) {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.shouldDeleteInaccessibleFaults = true
    
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "isSync == FALSE")
    
    context
      .perform {
        do {
          try context
            .fetch(fetchRequest)
            .forEach { mo in
              notesAPI
                .createNote(title: mo.title ?? "", text: mo.text ?? "")
                .sink(
                  receiveCompletion: { _ in },
                  receiveValue: { note in
                    mo.configure(note: note)
                    
                    do {
                      try context.save()
                    } catch {
                      context.rollback()
                    }
                  }
                )
                .store(in: &API.cancellables)
            }
        } catch { print("Error occured while fetching non sync notes, error: \(error.localizedDescription)") }
      }
  }
  
  func save() {
    backgroundContext.perform { [unowned self] in
      if backgroundContext.hasChanges {
        do {
          try backgroundContext.save()
        } catch {
          print("Error occured while save background context: \(error.localizedDescription)")
        }
      }
    }
  }
  
  func removeAll() {
    let context = persistentContainer.newBackgroundContext()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    context
      .perform {
        do {
          try context.execute(deleteRequest)
          try context.save()
        } catch {
          print("Error occured while delete notes: \(error.localizedDescription)")
        }
      }
  }
}

import Foundation
import CoreData
import Combine
import UIKit

class CoreDataManager {
  
  private let containerName: String
  private var cancellables: Set<AnyCancellable> = []
  
  init(containerName: String) {
    self.containerName = containerName
    setupObserving()
  }
  
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
  
  var newBackgroundContext: NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.parent = viewContext
    return context
  }
}

// MARK: - Setup Observing
private extension CoreDataManager {
  
  func setupObserving() {
    let willTerminate = NotificationCenter
      .default
      .publisher(for: UIApplication.willTerminateNotification)
    
    let didEnterBackground = NotificationCenter
      .default
      .publisher(for: UIApplication.didEnterBackgroundNotification)
    
    willTerminate.merge(with: didEnterBackground)
      .map { _ in () }
      .sink(receiveValue: weakify(CoreDataManager.save, object: self))
      .store(in: &cancellables)
  }
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
  
  func removeAllEntitieas(named entityName: String) {
    let context = newBackgroundContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    context
      .perform {
        do {
          try context.execute(deleteRequest)
          try context.save()
          weakify(CoreDataManager.save, object: self)()
        } catch {
          print("Error occured while delete entities named \(entityName)\n", error.localizedDescription)
        }
      }
  }
}

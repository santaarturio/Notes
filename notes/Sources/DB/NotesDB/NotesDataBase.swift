import SwiftUI
import Combine
import CoreData

final class NotesDataBase: NSObject, NotesDataBaseProtocol {
  
  private var cancellables: Set<AnyCancellable> = []

  private let coreDataManager = CoreDataManager(containerName: "NotesData")
  private var fetchedResultsController: NSFetchedResultsController<Note>!
  
  @Published private var notes: [Note] = []
  var notesPublisher: Published<[Note]>.Publisher { $notes }

  override init() {
    super.init()
    
    setupFetchedResultsController()
    
    KeyHolder
      .default
      .$isUserLoggedIn
      .filter { $0 }
      .map { _ in () }
      .sink(receiveValue: weakify(NotesDataBase.refreshFetchedResultsController, object: self))
      .store(in: &cancellables)
  }
  
  func updateNote(id: String, _ configurationsHandler: @escaping (Note) -> Void) {
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    
    coreDataManager
      .viewContext
      .perform { [unowned self] in
        do {
          let note = try coreDataManager.viewContext.fetch(fetchRequest).first ?? Note(context: coreDataManager.viewContext)
          configurationsHandler(note)
        } catch {
          print("Error occured while updating notes: \(error.localizedDescription)")
        }
      }
  }

  func createNote(with configurationsHandler: @escaping (Note) -> Void) {
    coreDataManager
      .viewContext
      .perform { [unowned self] in
        configurationsHandler(Note(context: coreDataManager.viewContext))
      }
  }
  
  func allAnsynced(_ closure: @escaping ([Note]) -> Void) {
    let context = coreDataManager.viewContext
    
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor.init(keyPath: \Note.date, ascending: true)]
    fetchRequest.addPredicates([NSPredicate(format: "isSync == FALSE")])
    
    context
      .perform {
        do {
          try closure(context.fetch(fetchRequest))
        } catch {
          print("Error occured while fetching non sync notes, error: \(error.localizedDescription)")
        }
      }
  }

  func removeAllNotes() {
    coreDataManager
      .removeAllEntities(named: "Note")
  }
  
  func saveAllChanges() {
    coreDataManager
      .save()
  }
}

// MARK: - NSFetchedResultsController
extension NotesDataBase: NSFetchedResultsControllerDelegate {
  
  private func setupFetchedResultsController() {
    let fetchRequest = Note.fetchRequest() as NSFetchRequest
    fetchRequest.sortDescriptors = [
      NSSortDescriptor(keyPath: \Note.date, ascending: false)
    ]
    
    fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: coreDataManager.viewContext,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    
    fetchedResultsController.delegate = self
  }
  
  func controllerDidChangeContent(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>
  ) { syncList() }
  
  private func refreshFetchedResultsController() {
    do {
      fetchedResultsController.fetchRequest.addPredicates()
      try fetchedResultsController.performFetch()
      syncList()
    } catch { print(error.localizedDescription) }
  }
  
  private func syncList() {
    fetchedResultsController
      .fetchedObjects
      .map { notes in self.notes = notes }
  }
}

private extension NSFetchRequest {
  
  @objc func addPredicates(_ predicates: [NSPredicate] = []) {
    let creatorId = KeyHolder.default.get(.userId) ?? ""
    predicate = NSCompoundPredicate(
      type: .and,
      subpredicates: predicates + [NSPredicate(format: "creatorId == %@", creatorId)]
    )
  }
}

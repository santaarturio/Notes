import SwiftUI
import Combine
import CoreData

final class NotesDataBase: NSObject, NotesDataBaseProtocol {
  
  private var cancellables: Set<AnyCancellable> = []
  private var authorPredicate: NSPredicate { .init(format: "creatorId == %@", KeyHolder.default.get(.userId) ?? "") }

  private let coreDataManager: CoreDataManager
  private var fetchedResultsController: NSFetchedResultsController<Note>!
  
  @Published private var notes: [Note] = []
  var notesPublisher: Published<[Note]>.Publisher { $notes }
  
  init(coreDataManager: CoreDataManager) {
    self.coreDataManager = coreDataManager
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
    fetchRequest.sortDescriptors = [
      NSSortDescriptor(keyPath: \Note.date, ascending: true)
    ]
    fetchRequest.predicate = NSCompoundPredicate(
      type: .and,
      subpredicates: [NSPredicate(format: "isSync == FALSE"), authorPredicate]
    )
    
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
      fetchedResultsController.fetchRequest.predicate = authorPredicate
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

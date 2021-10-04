import SwiftUI
import CoreData

final class NotesDataBase: NSObject, NotesDataBaseProtocol {

  private let coreDataManager = CoreDataManager(containerName: "NotesData")
  private var fetchedResultsController: NSFetchedResultsController<Note>!
  
  @Published private var notes: [Note] = []
  var notesPublisher: Published<[Note]>.Publisher { $notes }

  override init() {
    super.init()
    setupFetchedResultsController()
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
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.date, ascending: false)]
    
    fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: coreDataManager.viewContext,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    fetchedResultsController.delegate = self
    
    do {
      try fetchedResultsController.performFetch()
      syncList()
    } catch { print(error.localizedDescription) }
  }
  
  func controllerDidChangeContent(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>
  ) { syncList() }
  
  private func syncList() {
    fetchedResultsController
      .fetchedObjects
      .map { notes in self.notes = notes }
  }
}

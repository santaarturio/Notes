import SwiftUI
import CoreData

final class NotesListViewModel: NSObject, ObservableObject {
  
  private let api: NotesAPIProtocol
  private let factory: FactoryProtocol = Factory()
  
  private var fetchedResultsController: NSFetchedResultsController<NoteMO>!
  @Published var notes: [Note] = []
  
  let logout: () -> Void = { KeyHolder.default.flush() }
  var creationView: AnyView {
    AnyView(factory.makeNotesCreationView())
  }
  
  init(api: NotesAPIProtocol) {
    self.api = api
    super.init()
    
    setupFetchedResultsController()
    setupNetworking()
  }
  
  private func syncList() {
    guard
      let objects = fetchedResultsController.fetchedObjects else { return }
    
    notes = objects.map(Note.init)
  }
}

// MARK: - NSFetchedResultsController
extension NotesListViewModel: NSFetchedResultsControllerDelegate {
  
  private func setupFetchedResultsController() {
    let fetchRequest = NoteMO.fetchRequest() as NSFetchRequest
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    
    fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: CoreDataManager.instance.viewContext,
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
}

// MARK: - NSFetchedResultsController
private extension NotesListViewModel {
  
  func setupNetworking() {
    // TODO: refresh token
    fetchNotes()
  }
  
  func fetchNotes() {
    api
      .fetchNotes { result in
        switch result {
        case let .success(dtos):
          dtos
            .map(Note.init)
            .forEach { note in
              let entity = NoteMO(context: CoreDataManager.instance.viewContext)
              entity.id = note.id.string
              entity.title = note.title
              entity.text = note.text
            }
          CoreDataManager.instance.saveContext()
          
        case let .failure(error):
          print(error.localizedDescription)
        }
      }
  }
}

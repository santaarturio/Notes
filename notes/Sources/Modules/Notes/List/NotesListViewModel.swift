import SwiftUI
import Combine
import CoreData

final class NotesListViewModel: NSObject, ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  private var fetchedResultsController: NSFetchedResultsController<Note>!
  
  private let loginAPI: LoginAPIProtocol
  private let notesAPI: NotesAPIProtocol
  private let factory: FactoryProtocol = Factory()
  
  @Published var notes: [Note] = []
  
  let logout: () -> Void = {
    KeyHolder.default.flush()
    CoreDataManager.instance.removeAll(entities: Note.self)
  }
  
  var creationView: AnyView {
    AnyView(factory.makeNotesCreationView())
  }
  
  init(
    loginAPI: LoginAPIProtocol,
    notesAPI: NotesAPIProtocol
  ) {
    self.loginAPI = loginAPI
    self.notesAPI = notesAPI
    
    super.init()
    
    setupFetchedResultsController()
    setupNetworking()
  }
}

// MARK: - Sync
private extension NotesListViewModel {
  
  func syncList() {
    guard
      let managedObjects = fetchedResultsController.fetchedObjects else { return }
    notes = managedObjects
  }
}

// MARK: - NSFetchedResultsController
extension NotesListViewModel: NSFetchedResultsControllerDelegate {
  
  private func setupFetchedResultsController() {
    let fetchRequest = Note.fetchRequest() as NSFetchRequest
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    
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

// MARK: - Networking
private extension NotesListViewModel {
  
  // MARK: Refresh Token
  func setupNetworking() {
    let keyHolder: KeyHolder = .default
    
    loginAPI
      .signIn(
        email: keyHolder.get(.email) ?? "",
        password: keyHolder.get(.password) ?? ""
      )
      .sink(
        receiveCompletion: weakify(NotesListViewModel.fetchNotes, object: self),
        receiveValue: { KeyHolder.default.update($0.jwt ?? "", for: .token) }
      )
      .store(in: &cancellables)
  }
  
  // MARK: Fetch Notes
  func fetchNotes(_ completion: Subscribers.Completion<Error>) {
    guard case .finished = completion else { return }
    
    notesAPI
      .fetchNotes()
      .sink(
        receiveCompletion: weakify(NotesListViewModel.syncNotesIfNeeded, object: self),
        receiveValue: { dtos in
          let manager = CoreDataManager.instance
          
          dtos
            .enumerated()
            .forEach { index, note in
              manager
                .backgroundContext
                .perform {
                  let entity = Note(context: manager.backgroundContext)
                  entity.id = note.id
                  entity.title = note.title
                  entity.text = note.subtitle
                  entity.date = DateFormatter.cached.date(from: note.date)
                  entity.isSync = true
                }
            }
          
          manager.saveBackgroundContext()
        }
      )
      .store(in: &cancellables)
  }
  
  // MARK: Sync Untracked Notes
  func syncNotesIfNeeded(_ completion: Subscribers.Completion<Error>) {
    guard case .finished = completion else { return }
    
    let context = CoreDataManager.instance.persistentContainer.newBackgroundContext()
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "isSync == FALSE")
    
    context
      .perform { [weak self] in
        do {
          try context
            .fetch(fetchRequest)
            .forEach { mo in
              self?
                .notesAPI
                .createNote(title: mo.title ?? "", text: mo.text ?? "")
                .sink(
                  receiveCompletion: { _ in },
                  receiveValue: { dto in
                    
                    mo.id = dto.id
                    mo.isSync = true
                    
                    do {
                      try context.save()
                    } catch {
                      context.rollback()
                    }
                  }
                )
                .store(in: &NotesAPI.cancellables)
            }
        } catch { print("Error occured while fetching non sync notes, error: \(error.localizedDescription)") }
      }
  }
}

private extension NotesAPI {
  static var cancellables: Set<AnyCancellable> = []
}

import SwiftUI
import Combine
import CoreData

final class NotesListViewModel: NSObject, ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  private var fetchedResultsController: NSFetchedResultsController<Note>!
  
  private let loginAPI: LoginAPIProtocol
  private let notesAPI: NotesAPIProtocol
  private let dataBaseManager: NotesDataBaseProtocol
  private let factory: FactoryProtocol = Factory()
  
  @Published var notes: [Note] = []
  
  lazy var logout: () -> Void = { [weak dataBaseManager] in
    KeyHolder.default.flush()
    dataBaseManager?.removeAll()
  }
  
  var creationView: AnyView {
    AnyView(factory.makeNotesCreationView())
  }
  
  init(
    loginAPI: LoginAPIProtocol,
    notesAPI: NotesAPIProtocol,
    dataBaseManager: NotesDataBaseProtocol
  ) {
    self.loginAPI = loginAPI
    self.notesAPI = notesAPI
    self.dataBaseManager = dataBaseManager
    
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
      managedObjectContext: dataBaseManager.viewContext,
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
    loginAPI
      .refreshToken()
      .sink(
        receiveCompletion: weakify(NotesListViewModel.fetchNotes, object: self),
        receiveValue: { }
      )
      .store(in: &API.cancellables)
  }
  
  // MARK: Fetch Notes
  func fetchNotes(_ completion: Subscribers.Completion<Error>) {
    guard
      case .finished = completion else { return }
    
    notesAPI
      .fetchNotes()
      .sink(
        receiveCompletion: weakify(NotesListViewModel.syncNotesIfNeeded, object: self),
        receiveValue: { [weak dataBaseManager] dtos in
          dtos.forEach { note in dataBaseManager?.create { $0.configure(note: note) } }
          dataBaseManager?.save()
        }
      )
      .store(in: &API.cancellables)
  }
  
  // MARK: Sync Untracked Notes
  func syncNotesIfNeeded(_ completion: Subscribers.Completion<Error>) {
    guard
      case .finished = completion else { return }
    
    dataBaseManager
      .syncUnsynced(notesAPI: NotesAPI())
  }
}

extension API {
  static var cancellables: Set<AnyCancellable> = []
}

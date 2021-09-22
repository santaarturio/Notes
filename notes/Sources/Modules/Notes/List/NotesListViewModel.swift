import SwiftUI
import Combine
import CoreData

final class NotesListViewModel: NSObject, ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  private var fetchedResultsController: NSFetchedResultsController<NoteMO>!
  
  private let loginAPI: LoginAPIProtocol
  private let notesAPI: NotesAPIProtocol
  private let factory: FactoryProtocol = Factory()
  
  @Published var notes: [Note] = []
  
  let logout: () -> Void = { KeyHolder.default.flush() }
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

// MARK: - Networking
private extension NotesListViewModel {
  
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
  
  func fetchNotes(_ completion: Subscribers.Completion<Error>) {
    guard case .finished = completion else { return }
    
    notesAPI
      .fetchNotes()
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { dtos in
          dtos
            .map(Note.init)
            .forEach { note in
              let entity = NoteMO(context: CoreDataManager.instance.backgroundContext)
              entity.id = note.id.string
              entity.title = note.title
              entity.text = note.text
            }
          
          CoreDataManager.instance.saveBackgroundContext()
        }
      )
      .store(in: &cancellables)
  }
}

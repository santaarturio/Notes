import Combine
import CoreData

// MARK: - NotesDataBase
final class NotesDataBase {
  
  static let shared: NotesDataBase = .init(coreDataManager: .init(containerName: "NotesData"))
  
  private let coreDataManager: CoreDataManager
  private let loginAPI: LoginAPIProtocol
  private let notesAPI: NotesAPIProtocol
  
  init(
    coreDataManager: CoreDataManager,
    loginAPI: LoginAPIProtocol = LoginAPI(),
    notesAPI: NotesAPIProtocol = NotesAPI()
  ) {
    self.coreDataManager = coreDataManager
    self.loginAPI = loginAPI
    self.notesAPI = notesAPI
  }
}

// MARK: - NotesDataBaseProtocol
extension NotesDataBase: NotesDataBaseProtocol {
  
  var viewContext: NSManagedObjectContext { coreDataManager.viewContext }
  
  func create(title: String?, text: String?) {
    notesAPI
      .createNote(title: title ?? "", text: text ?? "")
      .sink(
        receiveCompletion: { [weak self] completion in
          
          guard
            case let .failure(error) = completion else { return }
          
          print("Error occured while creating new note: \(error.localizedDescription)")
          print("Saving offline")
          
          self?
            .coreDataManager
            .create(title: title, text: text)
        },
        receiveValue: { [weak coreDataManager] note in coreDataManager?.create(from: note) }
      )
      .store(in: &API.cancellables)
  }
  
  func removeAll() { coreDataManager.removeAllEntities(named: "Note") }
}

// MARK: - Setup
extension NotesDataBase {
  
  func setup() {
    loginAPI
      .refreshToken()
      .sink(
        receiveCompletion: weakify(NotesDataBase.fetchNotes, object: self),
        receiveValue: { }
      )
      .store(in: &API.cancellables)
  }
  
  private func fetchNotes(_ completion: Subscribers.Completion<Error>) {
    guard
      case .finished = completion else { return }
    
    notesAPI
      .fetchNotes()
      .sink(
        receiveCompletion: weakify(NotesDataBase.syncUnsyncedIfNeeded, object: self),
        receiveValue: { [weak self] dtos in self?.coreDataManager.sync(with: dtos) }
      )
      .store(in: &API.cancellables)
  }
  
  private func syncUnsyncedIfNeeded(_ completion: Subscribers.Completion<Error>) {
    guard
      case .finished = completion else { return }
    
    coreDataManager
      .syncUnsynced(notesAPI: notesAPI)
  }
}

// MARK: - Create
private extension CoreDataManager {
  
  func create(title: String?, text: String?) {
    let context = newBackgroundContext
    let noteMO = Note(context: context)
    
    context
      .perform {
        noteMO.id = Date().description
        noteMO.title = title
        noteMO.text = text
        noteMO.date = Date()
        noteMO.isSync = false
      }
    
    save(context: context)
  }
  
  func create(from note: API.Note) {
    let context = newBackgroundContext
    let noteMO = Note(context: context)
    
    context
      .perform {
        noteMO.configure(note: note)
      }
    
    save(context: context)
  }
}

// MARK: - Sync
private extension CoreDataManager {
  
  func sync(with notes: [API.Note]) {
    let context = newBackgroundContext
    
    notes.forEach { note in
      let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "id == %@", note.id.description)
      
      do {
        (try context.fetch(fetchRequest).first ?? Note(context: context))
          .configure(note: note)
      } catch {
        print("Error occured while sync dtos: \(error.localizedDescription)")
      }
    }
    
    save(context: context)
  }
  
  func syncUnsynced(notesAPI: NotesAPIProtocol) {
    let context = newBackgroundContext
    
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor.init(keyPath: \Note.date, ascending: true)]
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
}

extension API {
  static var cancellables: Set<AnyCancellable> = []
}

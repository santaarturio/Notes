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
  
  func removeAll() { coreDataManager.removeAll() }
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
        receiveCompletion: weakify(NotesDataBase.syncNotesIfNeeded, object: self),
        receiveValue: { [weak self] dtos in self?.coreDataManager.createMany(from: dtos) }
      )
      .store(in: &API.cancellables)
  }
  
  private func syncNotesIfNeeded(_ completion: Subscribers.Completion<Error>) {
    guard
      case .finished = completion else { return }
    
    coreDataManager
      .syncUnsynced(notesAPI: notesAPI)
  }
}

// MARK: - Convenience CoreDataManager extension
private extension CoreDataManager {
  
  func create(configurations configure: @escaping (Note) -> Void) {
    backgroundContext.perform { [unowned self] in
      configure(Note(context: backgroundContext))
    }
  }
  
  func create(title: String?, text: String?) {
    create { mo in
      mo.id = Date().description
      mo.title = title
      mo.text = text
      mo.date = Date()
      mo.isSync = false
    }
    save()
  }
  
  func create(from note: API.Note) {
    create { $0.configure(note: note) }
    save()
  }
  
  func createMany(from notes: [API.Note]) {
    notes.forEach { note in create { $0.configure(note: note) } }
    save()
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
  
  func syncUnsynced(notesAPI: NotesAPIProtocol) {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.shouldDeleteInaccessibleFaults = true
    
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

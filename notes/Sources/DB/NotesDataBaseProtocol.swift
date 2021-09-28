import CoreData

protocol NotesDataBaseProtocol: AnyObject {
  static var shared: NotesDataBaseProtocol { get }
  var viewContext: NSManagedObjectContext { get }
  
  func create(configurations: @escaping (Note) -> Void)
  func save()
  func syncUnsynced(notesAPI: NotesAPIProtocol)
  func removeAll()
}

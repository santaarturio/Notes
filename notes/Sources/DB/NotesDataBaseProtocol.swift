import Combine
import CoreData

protocol NotesDataBaseProtocol: AnyObject {
  var viewContext: NSManagedObjectContext { get }
  
  func setup()
  func create(title: String?, text: String?)
  func removeAll()
}

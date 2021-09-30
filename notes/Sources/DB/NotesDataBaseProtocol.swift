import Combine
import CoreData

protocol NotesDataBaseProtocol: AnyObject {
  var viewContext: NSManagedObjectContext { get }
  
  func create(title: String?, text: String?)
  func removeAll()
}

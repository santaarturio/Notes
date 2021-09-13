import UIKit

final class NotesTableVC: UITableViewController, Bindable {
  
  var viewModel: NotesViewModel!
  
  func bind(_ viewModel: NotesViewModel) {
    self.viewModel = viewModel
  }
  
}

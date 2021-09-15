import UIKit

final class NotesTableVC: UITableViewController, Bindable {
  
  var viewModel: NotesViewModel!
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.loginIfNeeded.send()
  }
  
  func bind(_ viewModel: NotesViewModel) {
    self.viewModel = viewModel
  }
}

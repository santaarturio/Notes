import UIKit

final class NotesTableVC: UITableViewController, Bindable {
  
  var viewModel: NotesViewModel!
  private let router: Router = .shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if KeyHolder.isUserLoggedIn == false { router.navigate(to: .login) }
  }
  
  func bind(_ viewModel: NotesViewModel) {
    self.viewModel = viewModel
  }
  
}

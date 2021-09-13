import UIKit

final class Factory: FactoryProtocol {
  
  func makeLoginVC() -> UIViewController {
    let vc = LoginVC()
    let viewModel = LoginViewModel()
    vc.bind(viewModel)
    return vc
  }
  
  func makeNotesVC() -> UIViewController {
    let vc = NotesTableVC()
    let viewModel = NotesViewModel()
    vc.bind(viewModel)
    return vc
  }
}

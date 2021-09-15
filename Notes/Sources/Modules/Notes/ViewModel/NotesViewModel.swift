import Foundation
import Combine

final class NotesViewModel {
  
  private let api: NotesAPI
  private let navigator: NotesNavigator
  
  private var cancellables: Set<AnyCancellable> = []
  
  //MARK: - Input
  let loginIfNeeded = PassthroughSubject<Void, Never>()
  
  init(
    api: NotesAPI,
    navigator: NotesNavigator
  ) {
    self.api = api
    self.navigator = navigator
    
    bindData()
  }
  
}

// MARK: - Bind Data
extension NotesViewModel {
  
  func bindData() {
    loginIfNeeded
      .filter { KeyHolder.isUserLoggedIn == false }
      .map { .login }
      .sink(receiveValue: weakify(NotesNavigator.navigate, object: navigator))
      .store(in: &cancellables)
  }
}

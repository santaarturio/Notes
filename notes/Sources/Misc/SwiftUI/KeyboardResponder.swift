import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
  private var cancellables: Set<AnyCancellable> = []
  
  @Published private(set) var isKeyboardShown = false
  @Published private(set) var keyboardHeight: CGFloat = 0
  
  init() {
    
    let show = NotificationCenter
      .default
      .publisher(for: UIResponder.keyboardWillShowNotification)
      .map { notification -> (Bool, CGFloat) in
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
          .cgRectValue ?? .zero
        return (true, rect.height)
      }
    
    let hide = NotificationCenter
      .default
      .publisher(for: UIResponder.keyboardDidHideNotification)
      .map { _ in (false, CGFloat.zero) }
    
    show.merge(with: hide)
      .sink(receiveValue: { [weak self] tuple in
        self?.isKeyboardShown = tuple.0
        self?.keyboardHeight = tuple.1
      })
      .store(in: &cancellables)
  }
}

func endEditing() {
  UIApplication
    .shared
    .sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil, from: nil, for: nil
    )
}

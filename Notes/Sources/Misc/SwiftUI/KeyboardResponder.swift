import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
  private var cancellables: Set<AnyCancellable> = []
  
  @Published private(set) var isKeyboardShown = false
  @Published private(set) var keyboardHeight: CGFloat = 0
  
  init() {
    let willShow = NotificationCenter
      .default
      .publisher(for: UIResponder.keyboardWillShowNotification)
      .map { notification -> CGFloat in
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
          .cgRectValue ?? .zero
        return rect.height
      }
    
    let show = willShow
      .zip(willShow.dropFirst())
      .map(max)
      .map { (true, $0) }
    
    let hide = NotificationCenter
      .default
      .publisher(for: UIResponder.keyboardWillHideNotification)
      .map { _ in (false, CGFloat.zero) }
    
    show.merge(with: hide)
      .sink(receiveValue: { [weak self] tuple in
        self?.isKeyboardShown = tuple.0
        self?.keyboardHeight = tuple.1
      })
      .store(in: &cancellables)
  }
}

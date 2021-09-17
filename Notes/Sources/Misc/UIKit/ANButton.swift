import UIKit

final class ANButton: UIButton {
  
  override var isHighlighted: Bool {
    didSet {
      UIView
        .animate(withDuration: 0.15) { [weak self] in
          self?.transform = self?.isHighlighted ?? false
            ? .init(scaleX: 0.925, y: 0.925)
            : .identity
        }
    }
  }
}

import SwiftUI

extension Binding {
  func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Binding<NewValue> {
    Binding<NewValue>(get: { transform(wrappedValue) }, set: { _ in })
  }
}

import Foundation

struct Note: Identifiable {
  let id: ID; struct ID: Hashable, Equatable { let string: String }
  let title: String?
  let text: String?
}

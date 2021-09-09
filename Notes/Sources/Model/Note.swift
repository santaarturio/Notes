import Foundation

struct Note {
  let id: ID; struct ID: Hashable, Equatable { let string: String }
  let title: String?
  let text: String?
}

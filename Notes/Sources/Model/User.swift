import Foundation

struct User {
  let id: ID; struct ID: Hashable, Equatable { let string: String }
  let name: String
  let email: String
}


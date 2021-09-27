import Foundation

extension API {
  struct User: Codable {
    let jwt: String?
    let id: String
    let name: String
    let email: String
  }
}

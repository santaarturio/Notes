import Foundation

enum API {
  struct Note: Codable {
    let id: String
    let title: String
    let text: String
    let createdAt: Date
  }
}

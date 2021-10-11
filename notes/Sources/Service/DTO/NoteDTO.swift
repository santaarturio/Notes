import Foundation

enum API {
  struct Note: Codable {
    let id: String
    let title: String
    let subtitle: String
    let date: Date
  }
}

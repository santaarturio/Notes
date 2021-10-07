import Foundation

enum API {
  struct Note: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let date: Date
  }
}

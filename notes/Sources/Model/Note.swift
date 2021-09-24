import Foundation

struct Note: Identifiable {
  let id: ID; struct ID: Hashable, Equatable { let string: String }
  let title: String?
  let text: String?
  let date: Date?
}

extension Note {
  init(mo: NoteMO) {
    id = .init(string: mo.id ?? "")
    title = mo.title
    text = mo.text
    date = mo.date
  }
}
